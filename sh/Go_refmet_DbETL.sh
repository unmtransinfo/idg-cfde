#!/bin/bash
###
# Columns in refmet.csv.gz:
# 1. "refmet_name"
# 2. "super_class"
# 3. "main_class"
# 4. "sub_class"
# 5. "formula"
# 6. "exactmass"
# 7. "inchi_key"
# 8. "smiles"
# 9. "pubchem_cid"
###
#
DBNAME="refmet"
DBSCHEMA="public"
DBHOST="localhost"
#
REFMET_DIR="$(cd $HOME/../data/RefMet; pwd)"
csvfile="$REFMET_DIR/refmet.csv.gz"
#
cwd=$(pwd)
#
dropdb $DBNAME
createdb $DBNAME
#
gunzip -c $csvfile \
	|${cwd}/python/csv2sql.py create \
		--tablename "main" --fixtags --maxchar 2000 \
		--coltypes "CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,INT" \
	|psql -d $DBNAME
#
gunzip -c $csvfile \
	|${cwd}/python/csv2sql.py insert \
		--tablename "main" --fixtags --maxchar 2000 \
		--coltypes "CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,INT" \
	|psql -q -d $DBNAME
#
psql -d $DBNAME -c "COMMENT ON DATABASE $DBNAME IS 'RefMet: A Reference list of Metabolite names, from the Metabolomics Workbench'";
psql -d $DBNAME -c "COMMENT ON TABLE main IS 'RefMet: A Reference list of Metabolite names, from the Metabolomics Workbench'";
#
COLS="smiles refmet_name inchi_key"
for col in $COLS ; do
	psql -d $DBNAME -c "UPDATE main SET $col = NULL WHERE $col = ''";
done
#
### Create mols table for RDKit structural searching.
#
sudo -u postgres psql -d $DBNAME -c 'CREATE EXTENSION rdkit'
#
psql -d $DBNAME <<__EOF__
SELECT
	pubchem_cid,
	mol
INTO
	${DBSCHEMA}.mols
FROM
	(SELECT
		pubchem_cid,
		mol_from_smiles(smiles::cstring) AS mol
	FROM
		${DBSCHEMA}.main
	) tmp
WHERE
	mol IS NOT NULL
	;
__EOF__
#
psql -d $DBNAME -c "CREATE INDEX molidx ON ${DBSCHEMA}.mols USING gist(mol)"
#
#
### Add FPs to mols table.
psql -d $DBNAME -c "ALTER TABLE ${DBSCHEMA}.mols ADD COLUMN fp BFP"
psql -d $DBNAME -c "ALTER TABLE ${DBSCHEMA}.mols ADD COLUMN mfp BFP"
psql -d $DBNAME -c "ALTER TABLE ${DBSCHEMA}.mols ADD COLUMN ffp BFP"
psql -d $DBNAME -c "ALTER TABLE ${DBSCHEMA}.mols ADD COLUMN torsionbv BFP"
psql -d $DBNAME -c "UPDATE ${DBSCHEMA}.mols SET fp = rdkit_fp(mol)"
psql -d $DBNAME -c "UPDATE ${DBSCHEMA}.mols SET mfp = morganbv_fp(mol)"
psql -d $DBNAME -c "UPDATE ${DBSCHEMA}.mols SET ffp = featmorganbv_fp(mol)"
psql -d $DBNAME -c "UPDATE ${DBSCHEMA}.mols SET torsionbv = torsionbv_fp(mol)"
#
psql -d $DBNAME -c "CREATE INDEX fps_fp_idx ON ${DBSCHEMA}.mols USING gist(fp)"
psql -d $DBNAME -c "CREATE INDEX fps_mfp_idx ON ${DBSCHEMA}.mols USING gist(mfp)"
psql -d $DBNAME -c "CREATE INDEX fps_ffp_idx ON ${DBSCHEMA}.mols USING gist(ffp)"
psql -d $DBNAME -c "CREATE INDEX fps_ttbv_idx ON ${DBSCHEMA}.mols USING gist(torsionbv)"
#
#
### Convenience function:
#
psql -d $DBNAME <<__EOF__
CREATE OR REPLACE FUNCTION
	rdk_simsearch(smiles text)
RETURNS TABLE(pubchem_cid INT, mol mol, similarity double precision) AS
	\$\$
	SELECT
		pubchem_cid,mol,tanimoto_sml(rdkit_fp(mol_from_smiles(\$1::cstring)),fp) AS similarity
	FROM
		${DBSCHEMA}.mols
	WHERE
		rdkit_fp(mol_from_smiles(\$1::cstring))%fp
	ORDER BY
		rdkit_fp(mol_from_smiles(\$1::cstring))<%>fp
		;
	\$\$
LANGUAGE SQL STABLE
	;
__EOF__
#
###
psql -d $DBNAME -c "CREATE ROLE www WITH LOGIN PASSWORD 'foobar'"
psql -d $DBNAME -c "GRANT SELECT ON ALL TABLES IN SCHEMA ${DBSCHEMA} TO www"
psql -d $DBNAME -c "GRANT SELECT ON ALL SEQUENCES IN SCHEMA ${DBSCHEMA} TO www"
psql -d $DBNAME -c "GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA ${DBSCHEMA} TO www"
psql -d $DBNAME -c "GRANT USAGE ON SCHEMA ${DBSCHEMA} TO www"
#
