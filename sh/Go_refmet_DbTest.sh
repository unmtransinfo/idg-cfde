#!/bin/bash
###
#
DBNAME="refmet"
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
SELECT
	m.id,
	refmet.pubchem_cid,
	refmet.refmet_name,
	refmet.smiles,
	m.cansmi
FROM
	mols m
JOIN
	refmet ON (refmet.mol_id = m.id)
WHERE
	m.mol = 'NCCc1ccc(O)c(O)c1'
	;
__EOF__
#
# Substructure search:
#
psql -d $DBNAME <<__EOF__
SELECT
	m.id,
	refmet.pubchem_cid,
	refmet.refmet_name,
	refmet.smiles,
	m.cansmi
FROM
	mols m
JOIN
	refmet ON (refmet.mol_id = m.id)
WHERE
	m.mol @> 'C12CCCC1CCC1C2CCC2=CCCCC12'
	;
__EOF__
#
# Similarity search:
#
psql -d $DBNAME <<__EOF__
SELECT
	tanimoto_sml(rdkit_fp(mol_from_smiles('NCCc1ccc(O)c(O)c1'::cstring)),m.fp) AS "sim",
	m.id,
	refmet.pubchem_cid,
	refmet.refmet_name,
	m.cansmi
FROM
	mols m
JOIN
	refmet ON (refmet.mol_id = m.id)
WHERE
	rdkit_fp(mol_from_smiles('NCCc1ccc(O)c(O)c1'::cstring))%m.fp
ORDER BY
	sim DESC
	;
__EOF__
#
