--
SELECT
	dlp.lab_procedure_name,
	dlp.lab_procedure_mnemonic,
	dlp.lab_procedure_group,
	dlp.lab_super_group,
	dlp.loinc_code,
	count(DISTINCT flp.encounter_id) encounter_id_count,
	count(DISTINCT fe.patient_id) patient_id_count
FROM
	hf_f_lab_procedure flp
JOIN
	hf_f_encounter fe ON flp.encounter_id = fe.encounter_id
JOIN
	hf_d_lab_procedure dlp ON dlp.lab_procedure_id = flp.detail_lab_procedure_id
GROUP BY
	dlp.lab_procedure_name,
	dlp.lab_procedure_mnemonic,
	dlp.lab_procedure_group,
	dlp.lab_super_group,
	dlp.loinc_code
ORDER BY
        dlp.loinc_code
	;