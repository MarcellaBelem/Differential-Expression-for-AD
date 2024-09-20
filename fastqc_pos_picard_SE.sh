#!/bin/bash
#############
#Script Processamento de RNA-seq SE
#1- fastqc pós-picard
#
#data:03/09/2022
##########

#To accomplish fastp again / caso queira realizar o fastp novamente
#convert bam to fastq
# Input diretory with bam files / Diretório de entrada contendo os arquivos BAM
input_remove_duplicate="/data1/public/marcella/samples164/trimados_bam_remove_duplicate"


# out to fastq files remove_duplicates / saída para os fastq sem duplicatas
output_fastq="/data1/public/marcella/samples164/trimados_bam_remove_duplicate/fastq"

# Certifique-se de que o diretório de saída exista; se não, crie-o
mkdir -p "$output_fastq"

# Loop for select all samples and convert them / laço para pegar todas as amostras e converter
for file_bam in "$input_remove_duplicate"/*.remove_dedup.bam; do
        base_name=$(basename "$file_bam" .remove_dedup.bam)

  java -jar /data1/public/marcella/picard.jar SamToFastq I="$file_bam" FASTQ="$output_fastq/${base_name}.fastq"
done

#1-fastqc
## Putting input and output directories, make sure they exist / colocando os diretorios de entrada e saida e certificando-se que as pastas existem
input_dir="/data1/public/marcella/samples164/trimados_bam_remove_duplicate/fastq"
output_dir="/data1/public/marcella/samples164/trimados_bam_remove_duplicate/fastqc"
output_fastp_report="/data1/public/marcella/samples164/trimados_bam_remove_duplicate/fastq/fastp_report"


mkdir -p "$output_dir"
mkdir -p "$output_fastp_report"

#Loop for select all samples fastq / loop para rodar as amostras fastq
for file in "$input_dir"/*.fastq;do
        # Extract the base fastq filename without the extension /Extrair o nome base do arquivo fastq sem a extensao
        base_name=$(basename "$file" .fastq)
   #Create out file
        output_file="$output_dir/${base_name}.fastq"
  #report
        report_html="$output_fastp_report/${base_name}_fastp.html"

        fastp -i "$file" -o "$output_file" --dedup --trim_poly_g 10 --qualified_quality_phred 30 --unqualified_percent_limit 30  --n_base_limit 5 --average_qual 20 --low_complexity_filter  --complexity_threshold 30 --cut_window_size 4 --trim_front1 1 --trim_tail1 1 --html "$report_html" --thread 4
done

         fastqc "$file" -o "$output_dir"

         multiqc "$output_dir" -o "$output_dir"
         multiqc "$output_fastp_report" -o "$output_fastp_report"


