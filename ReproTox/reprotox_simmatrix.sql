SELECT DISTINCT
	mols_a.id cfchemdb_id_a,
	mols_a.pubchem_cid pubchem_cid_b,
	mols_b.id cfchemdb_id_b,
	mols_b.pubchem_cid pubchem_cid_b,
	ROUND(tanimoto_sml(mols_a.fp, mols_b.fp)::NUMERIC, 3) tanimoto_rdfp,
	ROUND(tanimoto_sml(mols_a.ecfp, mols_b.ecfp)::NUMERIC, 3) tanimoto_ecfp
FROM
	(SELECT mols.id,xrefs.xref_value pubchem_cid,mols.fp,mols.ecfp FROM mols JOIN reprotox ON reprotox.mol_id = mols.id JOIN xrefs ON xrefs.mol_id = mols.id WHERE xrefs.xref_type = 'pubchem_cid') mols_a,
	(SELECT mols.id,xrefs.xref_value pubchem_cid,mols.fp,mols.ecfp FROM mols JOIN reprotox ON reprotox.mol_id = mols.id JOIN xrefs ON xrefs.mol_id = mols.id WHERE xrefs.xref_type = 'pubchem_cid') mols_b
WHERE
        mols_a.id < mols_b.id
ORDER BY
        mols_a.id, mols_b.id
	;
