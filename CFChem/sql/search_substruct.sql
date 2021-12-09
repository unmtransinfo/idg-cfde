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
