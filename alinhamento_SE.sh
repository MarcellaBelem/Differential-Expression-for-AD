#!/bin/bash
#############
#Script para alinhamento e utilização no picard-remoção de duplicatas
#amostras Single-End (SE)
#data:27/07/2022
##########

input_dir="/data1/public/marcella/samples164/trimados"
input_genome_index="/data1/public/marcella/genome_index"

output_bam="/data1/public/samples164/sorted.bam"

mkdir -p "$output_bam"

#Baixar o arq fasta e as anotações do genoma de referencia
#cd "$input_genome_index"
# Baixar o genoma FASTA
#wget ftp://ftp.ensembl.org/pub/release-110/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz

# Baixar o arquivo GTF de anotações
#wget ftp://ftp.ensembl.org/pub/release-110/gtf/homo_sapiens/Homo_sapiens.GRCh38.110.gtf.gz

#descompactar os arquivos
#gunzip Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
#gunzip Homo_sapiens.GRCh38.110.gtf.gz

#da permisão para o arq fasta pode ser necessario
#chmod +r Homo_sapiens.GRCh38.dna.fa

#indice do genome de referencia

STAR --runMode genomeGenerate \
    --genomeDir "$input_genome_index"  \
    --genomeFastaFiles  "$input_genome_index"/Homo_sapiens.GRCh38.dna.fa\
    --sjdbGTFfile "$input_genome_index"/Homo_sapiens.GRCh38.110.gtf \
    --runThreadN 4

# Alinhar as leituras
for file_fastq in "$input_dir"/*.trimmed.fastq; do
    base_name=$(basename "$file_fastq" .trimmed.fastq)


STAR --genomeDir "$input_genome_index" --readFilesIn "$file_fastq" --outFileNamePrefix "$output_bam/$base_name." --runThreadN 4 --outSAMtype BAM SortedByCoordinate
done

##PICARD
        # Diretório de entrada contendo os arquivos BAM (substitua com o seu diretório)
#$output_bam

# Diretório de saída para arquivos marcados
output_remove_duplicate="/data1/public/marcella/samples164/trimados_bam_remove_duplicate"

# Certifique-se de que o diretório de saída exista; se não, crie-o
mkdir -p "${output_remove_duplicate}"

# Loop para marcar duplicatas em cada arquivo no diretório de entrada
for bam_file in "$output_bam"/*.Aligned.sortedByCoord.out.bam; do
    base_name=$(basename "$bam_file" .Aligned.sortedByCoord.out.bam)

  java -jar /data1/public/marcella/picard.jar MarkDuplicates REMOVE_DUPLICATES=true I="$bam_file" O="$output_remove_duplicate/$base_name.marked_remov.bam" M="$output_remove_duplicate/$base_name.metrics.txt"
done

