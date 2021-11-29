#!/bin/bash
###
#
DBNAME="cfchemdb"
DBSCHEMA="public"
DBHOST="localhost"
#
###
# Exact structure search:
# NOTE: @= operator does not work?  But = does.
#	m.mol @= 'NCCc1ccc(O)c(O)c1'
#	m.mol @= 'CNC[C@H](O)c1ccc(O)c(O)c1'
#
psql -d $DBNAME <<__EOF__
SELECT DISTINCT
	mols.id,
	mols.name,
	lincs.pert_name,
	lincs.sig_count,
	refmet.pubchem_cid,
	refmet.refmet_name
FROM
	mols
JOIN
	lincs ON (lincs.mol_id = mols.id)
JOIN
	refmet ON (refmet.mol_id = mols.id)
WHERE
	mols.molecule = 'NCCc1ccc(O)c(O)c1'
	;
__EOF__
#
# Substructure search:
#
psql -d $DBNAME <<__EOF__
SELECT
	mols.id,
	mols.name,
	lincs.pert_name,
	lincs.sig_count,
	refmet.pubchem_cid,
	refmet.refmet_name
FROM
	mols
JOIN
	lincs ON (lincs.mol_id = mols.id)
JOIN
	refmet ON (refmet.mol_id = mols.id)
WHERE
	mols.molecule @> 'C12CCCC1CCC1C2CCC2=CCCCC12'
	;
__EOF__
#
# Similarity search:
#
psql -d $DBNAME <<__EOF__
SELECT
	mols.id,
	mols.name,
	lincs.pert_name,
	lincs.sig_count,
	refmet.pubchem_cid,
	refmet.refmet_name,
	ROUND(tanimoto_sml(rdkit_fp(mol_from_smiles('NCCc1ccc(O)c(O)c1'::cstring)), mols.fp)::NUMERIC, 2) similarity
FROM
	mols
JOIN
	lincs ON (lincs.mol_id = mols.id)
JOIN
	refmet ON (refmet.mol_id = mols.id)
WHERE
	rdkit_fp(mol_from_smiles('NCCc1ccc(O)c(O)c1'::cstring))%mols.fp
ORDER BY
	similarity DESC
	;
__EOF__
#
