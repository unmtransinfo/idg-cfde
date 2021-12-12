SELECT
	mols_a.id mol_id_a,
	mols_a.ls_id ls_id_a,
	mols_b.id mol_id_b,
	mols_b.ls_id ls_id_b,
	ROUND(tanimoto_sml(mols_a.ecfp, mols_b.ecfp)::NUMERIC, 3) tanimoto_similarity
FROM
	(SELECT * FROM mols INNER JOIN reprotox ON reprotox.mol_id = mols.id) mols_a,
	(SELECT * FROM mols INNER JOIN reprotox ON reprotox.mol_id = mols.id) mols_b
WHERE
        mols_a.id <= mols_b.id
ORDER BY
        mols_a.id, mols_b.id
	;
