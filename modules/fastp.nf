/*
 * Run fastq on the read fastq files
 */
 process FASTP {

    label 'process_single'

    container "swglh/fastp:1.0.1"

    publishDir ("$params.outdir/FASTP", mode: "copy")

    input:
    tuple val(sample_id), path(reads)
    
    output:
    tuple val(sample_id), path(reads)

    tag { sample_id }

    script:
    """
    echo "Fastp preprocessing with ${sample_id}"

    fastp -i ${reads[0]} -I ${reads[1]} \
    -o ${sample_id}_R1_trimmed.fastq.gz \
    -O ${sample_id}_R2_trimmed.fastq.gz

    echo "FASTP Complete"
    """
}