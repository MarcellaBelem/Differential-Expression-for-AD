#!/bin/bash
#############
#Script FASTqc and RNA-seq SE data trimming
#1- fastqc, 2-trimming de RNA-seq
#
#data:21/07/2022
##########


#1-fastqc
input_dir="/data1/public/marcella/samples164"
output_dir_fastqc="/data1/public/marcella/samples164/fastqc"

mkdir -p "$output_dir_fastqc"
	fastqc "$input_dir"/*.fastq.gz -o "$output_dir_fastqc"

	multiqc ./"$output_dir_fastqc"

#2-Fastp (trimmming)
#create the output directory/ Criar o diretorio de saída
output_dir_trimados="/data1/public/marcella/samples164/trimados"
output_fastqc_trimados="/data1/public/marcella/samples164/fastqc_trimados"
output_fastp_report="/data1/public/marcella/samples164/report_fastp"

# Make sure it was created/ Ter certeza que foi criado
mkdir -p "$output_fastqc_trimados"
mkdir -p "$output_dir_trimados"
mkdir -p "$output_fastp_report"

#loop for processing all file in the folder / Loop para processar todas os arquivos na pasta
for file in "$input_dir"/*.fastq.gz;do
	# Extract base from fastq.gz filename without the extension / Extrair a base do nome do arquivo fastq.gz sem a extensao
	base_name=$(basename "$file".fastq.gz)
   #Create output file / criar arq de saida
	output_file="$output_dir_trimados/${base_name}.trimmed.fastq"
  #output file report / saída do relatorio
	report_html="$output_fastp_report/${base_name}_fastp.html"

	fastp -i "$file" -o "$output_file" --dedup -g 10 -q 30 -u 5 -n 20 -e 20 -y -Y 30 -W 4 -l 50 -f 1 -t 1 --html "$report_html" --thread 4
done

        fastqc "$output_dir_trimados"/*fastq -o "$output_fastqc_trimados"

        multiqc "$output_fastqc_trimados" -o "$output_fastqc_trimados"
        multiqc "$output_fastp_report" -o "$output_fastp_report"
