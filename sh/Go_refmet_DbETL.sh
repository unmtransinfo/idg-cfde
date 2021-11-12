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
		--tablename "refmet" --fixtags --maxchar 2000 \
		--coltypes "CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,INT" \
	|psql -d $DBNAME
#
gunzip -c $csvfile \
	|${cwd}/python/csv2sql.py insert \
		--tablename "refmet" --fixtags --maxchar 2000 \
		--coltypes "CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,CHAR,INT" \
	|psql -q -d $DBNAME
#
psql -d $DBNAME -c "COMMENT ON DATABASE $DBNAME IS 'RefMet: A Reference list of Metabolite names, from the Metabolomics Workbench'";
psql -d $DBNAME -c "COMMENT ON TABLE refmet IS 'RefMet: A Reference list of Metabolite names, from the Metabolomics Workbench'";
#
COLS="smiles refmet_name inchi_key"
for col in $COLS ; do
	psql -d $DBNAME -c "UPDATE refmet SET $col = NULL WHERE $col = ''";
done
#
### Create mols table for RDKit structural searching.
#
sudo -u postgres psql -d $DBNAME -c 'CREATE EXTENSION rdkit'
#
# N.B.: mol_to_smiles(mol) : returns the canonical SMILES for a molecule.
#
psql -d $DBNAME -c "ALTER TABLE refmet ADD COLUMN mol MOL"
psql -d $DBNAME -c "ALTER TABLE refmet ADD COLUMN cansmi VARCHAR(2000)"
psql -d $DBNAME -c "UPDATE refmet SET mol = mol_from_smiles(smiles::cstring)"
psql -d $DBNAME -c "UPDATE refmet SET cansmi = mol_to_smiles(mol)"
psql -d $DBNAME -c "ALTER TABLE refmet DROP COLUMN mol"
#
psql -d $DBNAME <<__EOF__
SELECT
	cansmi
INTO
	mols
FROM
	(SELECT DISTINCT cansmi FROM refmet) tmp
WHERE
	cansmi IS NOT NULL
	;
__EOF__
#
psql -d $DBNAME -c "ALTER TABLE mols ADD COLUMN id SERIAL PRIMARY KEY"
psql -d $DBNAME -c "ALTER TABLE mols ADD COLUMN name VARCHAR(100)"
psql -d $DBNAME -c "UPDATE mols SET name = refmet.refmet_name FROM refmet WHERE refmet.cansmi = mols.cansmi AND mols.cansmi IS NOT NULL"
#
psql -d $DBNAME -c "ALTER TABLE refmet ADD COLUMN mol_id INT"
psql -d $DBNAME -c "UPDATE refmet SET mol_id = m.id FROM mols m WHERE refmet.cansmi = m.cansmi"
#
psql -d $DBNAME -c "ALTER TABLE mols ADD COLUMN mol MOL"
psql -d $DBNAME -c "UPDATE mols SET mol = mol_from_smiles(cansmi::cstring)"
psql -d $DBNAME -c "CREATE INDEX molidx ON mols USING gist(mol)"
#
###
N_refmet_name=$(psql -d $DBNAME -qAc "SELECT COUNT(DISTINCT refmet_name) FROM refmet" |grep '^[0-9]')
N_cid=$(psql -d $DBNAME -qAc "SELECT COUNT(DISTINCT pubchem_cid) FROM refmet" |grep '^[0-9]')
N_cansmi=$(psql -d $DBNAME -qAc "SELECT COUNT(DISTINCT cansmi) FROM refmet" |grep '^[0-9]')
N_mol=$(psql -d $DBNAME -qAc "SELECT COUNT(*) FROM mols" |grep '^[0-9]')
printf "N_refmet_name: ${N_refmet_name}; N_cid: ${N_cid}; N_cansmi: ${N_cansmi}; N_mol: ${N_mol}\n"
#
### Add FPs to mols table.
# sfp : a sparse count vector fingerprint (SparseIntVect in C++ and Python)
# bfp : a bit vector fingerprint (ExplicitBitVect in C++ and Python)
###
# morgan_fp(mol,int default 2) : returns an sfp which is the count-based Morgan fingerprint for a molecule using connectivity invariants. The second argument provides the radius. This is an ECFP-like fingerprint.
# morganbv_fp(mol,int default 2) : returns a bfp which is the bit vector Morgan fingerprint for a molecule using connectivity invariants. The second argument provides the radius. This is an ECFP-like fingerprint.
# featmorgan_fp(mol,int default 2) : returns an sfp which is the count-based Morgan fingerprint for a molecule using chemical-feature invariants. The second argument provides the radius. This is an FCFP-like fingerprint.
# featmorganbv_fp(mol,int default 2) : returns a bfp which is the bit vector Morgan fingerprint for a molecule using chemical-feature invariants. The second argument provides the radius. This is an FCFP-like fingerprint.
# rdkit_fp(mol) : returns a bfp which is the RDKit fingerprint for a molecule. This is a daylight-fingerprint using hashed molecular subgraphs.
###
psql -d $DBNAME -c "ALTER TABLE mols ADD COLUMN fp BFP"
psql -d $DBNAME -c "ALTER TABLE mols ADD COLUMN mfp BFP"
psql -d $DBNAME -c "ALTER TABLE mols ADD COLUMN ffp BFP"
psql -d $DBNAME -c "ALTER TABLE mols ADD COLUMN torsionbv BFP"
psql -d $DBNAME -c "UPDATE mols SET fp = rdkit_fp(mol)"
psql -d $DBNAME -c "UPDATE mols SET mfp = morganbv_fp(mol)"
psql -d $DBNAME -c "UPDATE mols SET ffp = featmorganbv_fp(mol)"
psql -d $DBNAME -c "UPDATE mols SET torsionbv = torsionbv_fp(mol)"
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
RETURNS TABLE(pubchem_cid INT, mol MOL, similarity double precision) AS
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
