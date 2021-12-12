SELECT DISTINCT
	mols_a.id mol_id_a,
	mols_b.id mol_id_b,
	ROUND(tanimoto_sml(mols_a.fp, mols_b.fp)::NUMERIC, 3) tanimoto_rdfp,
	ROUND(tanimoto_sml(mols_a.ecfp, mols_b.ecfp)::NUMERIC, 3) tanimoto_ecfp
FROM
	(SELECT id,fp,ecfp FROM mols INNER JOIN reprotox ON reprotox.mol_id = mols.id) mols_a,
	(SELECT id,fp,ecfp FROM mols INNER JOIN reprotox ON reprotox.mol_id = mols.id) mols_b
WHERE
        mols_a.id < mols_b.id
ORDER BY
        mols_a.id, mols_b.id
	;
