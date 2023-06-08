

def tsv_to_md(tsv_file, md_file):
    with open(tsv_file, 'r') as tsv:
        with open(md_file, 'w') as md:
            lines = tsv.readlines()
            headers = lines[0].strip().split('\t')
            md.write('| ' + ' | '.join(headers) + ' |\n')
            md.write('| ' + ' | '.join(['---' for _ in headers]) + ' |\n')
            for line in lines[1:]:
                values = line.strip().split('\t')
                md.write('| ' + ' | '.join(values) + ' |\n')

    print(f"Conversion completed. TSV file '{tsv_file}' converted to MD file '{md_file}'.")
    
tsv_file_path = 'tcrd_data_dictionary.tsv'
md_file_path = 'tcrd_data_dictionary.md'
tsv_to_md(tsv_file_path, md_file_path)    

