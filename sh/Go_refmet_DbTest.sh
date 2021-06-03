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
	m.pubchem_cid,
	s.refmet_name,
	mol_to_smiles(m.mol) AS "smiles"
FROM
	$DBSCHEMA.mols m
JOIN
	$DBSCHEMA.main s ON (s.pubchem_cid = m.pubchem_cid)
WHERE
	m.mol = 'NCCc1ccc(O)c(O)c1'
	;
__EOF__
#
# Substructure search:
#
psql -d $DBNAME <<__EOF__
SELECT
	m.pubchem_cid,
	s.refmet_name,
	mol_to_smiles(m.mol) AS "smiles"
FROM
	$DBSCHEMA.mols m
JOIN
	$DBSCHEMA.main s ON (s.pubchem_cid = m.pubchem_cid)
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
	m.pubchem_cid,
	s.refmet_name,
	mol_to_smiles(m.mol) AS "smiles"
FROM
	$DBSCHEMA.mols m
JOIN
	$DBSCHEMA.main s ON (s.pubchem_cid = m.pubchem_cid)
WHERE
	rdkit_fp(mol_from_smiles('NCCc1ccc(O)c(O)c1'::cstring))%m.fp
ORDER BY
	sim DESC
	;
__EOF__
#
