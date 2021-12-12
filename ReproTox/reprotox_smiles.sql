SELECT
	cansmi,
	ls_id
FROM
	reprotox
WHERE
        cansmi IS NOT NULL
ORDER BY
	ls_id
	;
