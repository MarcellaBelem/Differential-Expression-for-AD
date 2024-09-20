#!/bin/bash
#############
#Script Counts of RNA-seq SE data
#
#data:04/09/2022
##########

# To install the HTSeq: pip install HTSeq

##Input directory of all sam samples and from annotation gtf of genome / usar arquivo bam gerado do picard
input_dir="/data1/public/marcella/samples164/trimados_bam_remove_duplicate"
input_gtf="/data1/public/marcella/genome_index/gencode.v46.annotation.gtf"

#out for sam and count files 
output_sam="/data1/public/marcella/samples164/trimados_bam_remove_duplicate/sam"
output_count="/data1/public/marcella/samples164/counts"

#mkdir -p "$output_sam"
#mkdir -p "$output_count"

#convert bam to sam 
#Loop for select all samples
for file_bam in "$input_dir"/*.remove_dedup.bam; do
    #Extract base from bam filename without the extension
    base_name=$(basename "$file_bam" .remove_dedup.bam)

    samtools view -h "$file_bam" > "$output_sam/${base_name}.sam"
done

#HTSeq-count
for file_sam in "$output_sam"/*.sam; do
    #Extract base from sam filename without the extension
    base_name_sam=$(basename "$file_sam" .sam)

    python -m HTSeq.scripts.count --stranded=no --format=sam -r name --type=exon --idattr=gene_id --additional-attr=gene_name --mode=union --nonunique=none --samout="$output_count/${base_name_sam}_counted.sam" "$file_sam" "$input_gtf" > "$output_count/${base_name_sam}_counts.txt" 2> "$output_count/${base_name_sam}_errors.log"
    
done
 