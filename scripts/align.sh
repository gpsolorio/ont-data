minimap2 -ax map-ont ref.fa reads.bam | samtools sort -o aligned.bam
samtools index aligned.bam
