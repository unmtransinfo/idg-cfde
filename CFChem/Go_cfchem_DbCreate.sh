#!/bin/bash
###
# https://www.rdkit.org/docs/Cartridge.html
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
T0=$(date +%s)
#
DBNAME="cfchemdb"
DBSCHEMA="public"
DBHOST="localhost"
#
cwd=$(pwd)
#
dropdb $DBNAME
createdb $DBNAME
psql -d $DBNAME -c "COMMENT ON DATABASE $DBNAME IS 'CFChemDb: Common Fund Data Ecosystem (CFDE) Chemical Database'";
###
# Create mols table for RDKit structural searching.
#sudo -u postgres psql -d $DBNAME -c 'CREATE EXTENSION rdkit'
psql -d $DBNAME -c 'CREATE EXTENSION rdkit'
#
# Molecules table:
psql -d $DBNAME <<__EOF__
CREATE TABLE mols (
	id SERIAL PRIMARY KEY,
	name VARCHAR(100),
	cansmi VARCHAR(2000),
	molecule MOL
	);
__EOF__
#
###
# LOAD RefMet:
REFMET_DIR="$(cd $HOME/../data/RefMet; pwd)"
refmet_csvfile="$REFMET_DIR/refmet.csv.gz"
#
TNAME="refmet"
gunzip -c $refmet_csvfile \
	|${cwd}/../python/csv2sql.py create \
		--tablename "${TNAME}" --fixtags --maxchar 2000 \
		--coltypes "CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,INT" \
	|psql -d $DBNAME
#
gunzip -c $refmet_csvfile \
	|${cwd}/../python/csv2sql.py insert \
		--tablename "${TNAME}" --fixtags --maxchar 2000 \
		--coltypes "CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,INT" \
	|psql -q -d $DBNAME
#
psql -d $DBNAME -c "COMMENT ON TABLE ${TNAME} IS 'RefMet: A Reference list of Metabolite names, from the Metabolomics Workbench'";
#
COLS="smiles refmet_name inchi_key"
for col in $COLS ; do
	psql -d $DBNAME -c "UPDATE ${TNAME} SET $col = NULL WHERE $col = ''";
done
#
# N.B.: mol_to_smiles(mol) : returns the canonical SMILES for a molecule.
#
psql -d $DBNAME -c "ALTER TABLE ${TNAME} ADD COLUMN mol MOL"
psql -d $DBNAME -c "ALTER TABLE ${TNAME} ADD COLUMN cansmi VARCHAR(2000)"
psql -d $DBNAME -c "UPDATE ${TNAME} SET mol = mol_from_smiles(smiles::cstring)"
psql -d $DBNAME -c "UPDATE ${TNAME} SET cansmi = mol_to_smiles(mol)"
psql -d $DBNAME -c "ALTER TABLE ${TNAME} DROP COLUMN mol"
#
psql -d $DBNAME <<__EOF__
INSERT INTO
	mols (cansmi, molecule)
SELECT
	${TNAME}.cansmi, mol_from_smiles(${TNAME}.cansmi::cstring)
FROM
	${TNAME}
WHERE
	${TNAME}.cansmi IS NOT NULL
	AND NOT EXISTS (SELECT cansmi FROM mols WHERE cansmi = ${TNAME}.cansmi)
	;
__EOF__
#
psql -d $DBNAME -c "ALTER TABLE ${TNAME} ADD COLUMN mol_id INT"
psql -d $DBNAME -c "UPDATE ${TNAME} SET mol_id = m.id FROM mols m WHERE ${TNAME}.cansmi = m.cansmi"
#
printf "REFMET: N_name:\t%6d\n" $(psql -d $DBNAME -qAc "SELECT COUNT(DISTINCT refmet_name) FROM ${TNAME}" |grep '^[0-9]')
printf "REFMET: N_cid:\t%6d\n" $(psql -d $DBNAME -qAc "SELECT COUNT(DISTINCT pubchem_cid) FROM ${TNAME}" |grep '^[0-9]')
printf "REFMET: N_cansmi:\t%6d\n" $(psql -d $DBNAME -qAc "SELECT COUNT(DISTINCT cansmi) FROM ${TNAME}" |grep '^[0-9]')
#
###
# LOAD LINCS:
# https://s3.amazonaws.com/lincs-dcic/sigcom-lincs-metadata/LINCS_small_molecules.tsv
LINCS_DIR="$(cd $HOME/../data/LINCS/data; pwd)"
lincs_csvfile="$LINCS_DIR/LINCS_small_molecules.tsv"
TNAME="lincs"
#pert_name, target, moa, canonical_smiles, inchi_key, compound_aliases, sig_count
cat $lincs_csvfile \
	|${cwd}/../python/csv2sql.py create --tsv \
		--tablename "${TNAME}" --fixtags --maxchar 2000 \
		--colnames "id,pert_name,target,moa,smiles,inchi_key,compound_aliases,sig_count" \
		--coltypes "CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,INT" \
	|psql -d $DBNAME
#
cat $lincs_csvfile \
	|${cwd}/../python/csv2sql.py insert --tsv \
		--tablename "${TNAME}" --fixtags --maxchar 2000 \
		--colnames "id,pert_name,target,moa,smiles,inchi_key,compound_aliases,sig_count" \
		--coltypes "CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,INT" \
	|psql -q -d $DBNAME
#
psql -d $DBNAME -c "COMMENT ON TABLE ${TNAME} IS 'LINCS: Small molecules from LINCS Sigcom download'";
#
COLS="pert_name target moa smiles inchi_key compound_aliases"
for col in $COLS ; do
	psql -d $DBNAME -c "UPDATE ${TNAME} SET $col = NULL WHERE $col = '' OR $col = '-'";
done
#
psql -d $DBNAME -c "ALTER TABLE ${TNAME} ADD COLUMN mol MOL"
psql -d $DBNAME -c "ALTER TABLE ${TNAME} ADD COLUMN cansmi VARCHAR(2000)"
psql -d $DBNAME -c "UPDATE ${TNAME} SET mol = mol_from_smiles(smiles::cstring)"
psql -d $DBNAME -c "UPDATE ${TNAME} SET cansmi = mol_to_smiles(mol)"
psql -d $DBNAME -c "ALTER TABLE ${TNAME} DROP COLUMN mol"
#
psql -d $DBNAME <<__EOF__
INSERT INTO
	mols (cansmi, molecule)
SELECT
	${TNAME}.cansmi, mol_from_smiles(${TNAME}.cansmi::cstring)
FROM
	${TNAME}
WHERE
	${TNAME}.cansmi IS NOT NULL
	AND NOT EXISTS (SELECT cansmi FROM mols WHERE cansmi = ${TNAME}.cansmi)
	;
__EOF__
#
psql -d $DBNAME -c "ALTER TABLE ${TNAME} ADD COLUMN mol_id INT"
psql -d $DBNAME -c "UPDATE ${TNAME} SET mol_id = m.id FROM mols m WHERE ${TNAME}.cansmi = m.cansmi"
#
#
###
printf "N_mol:\t%6d\n" $(psql -d $DBNAME -qAc "SELECT COUNT(*) FROM mols" |grep '^[0-9]')
###
# Postprocess molecules table for chemical search functionality.
psql -d $DBNAME -c "CREATE INDEX molidx ON mols USING gist(molecule)"
#
###
# Names?
#psql -d $DBNAME -c "UPDATE mols SET name = refmet.refmet_name FROM refmet WHERE refmet.cansmi = mols.cansmi AND mols.cansmi IS NOT NULL"
### Add FPs to mols table.
psql -d $DBNAME -c "ALTER TABLE mols ADD COLUMN fp BFP"
psql -d $DBNAME -c "ALTER TABLE mols ADD COLUMN mfp BFP"
psql -d $DBNAME -c "ALTER TABLE mols ADD COLUMN ffp BFP"
psql -d $DBNAME -c "ALTER TABLE mols ADD COLUMN torsionbv BFP"
psql -d $DBNAME -c "UPDATE mols SET fp = rdkit_fp(molecule)"
psql -d $DBNAME -c "UPDATE mols SET mfp = morganbv_fp(molecule)"
psql -d $DBNAME -c "UPDATE mols SET ffp = featmorganbv_fp(molecule)"
psql -d $DBNAME -c "UPDATE mols SET torsionbv = torsionbv_fp(molecule)"
#
psql -d $DBNAME -c "CREATE INDEX fps_fp_idx ON mols USING gist(fp)"
psql -d $DBNAME -c "CREATE INDEX fps_mfp_idx ON mols USING gist(mfp)"
psql -d $DBNAME -c "CREATE INDEX fps_ffp_idx ON mols USING gist(ffp)"
psql -d $DBNAME -c "CREATE INDEX fps_ttbv_idx ON mols USING gist(torsionbv)"
#
#
### Convenience function:
#
psql -d $DBNAME <<__EOF__
CREATE OR REPLACE FUNCTION
	rdk_simsearch(smiles TEXT)
RETURNS TABLE(pubchem_cid INT, molecule MOL, similarity double precision) AS
	\$\$
	SELECT
		refmet.mol_id,
		refmet.pubchem_cid,
		refmet.cansmi,
		ROUND(tanimoto_sml(rdkit_fp(mol_from_smiles(\$1::cstring)), m.fp)::NUMERIC, 3) AS similarity
	FROM
		${DBSCHEMA}.mols m
	JOIN
		${DBSCHEMA}.refmet ON refmet.mol_id = m.id
	WHERE
		rdkit_fp(mol_from_smiles(\$1::cstring))%m.fp
	ORDER BY
		rdkit_fp(mol_from_smiles(\$1::cstring))<%>m.fp
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
printf "Elapsed time: %ds\n" "$[$(date +%s) - ${T0}]"
#
