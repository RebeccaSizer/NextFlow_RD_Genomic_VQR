/*
 * Align reads to the indexed genome
 */
process alignReadsBowtie2 {
    
    container 'biocontainers/bowtie2:v2.4.1_cv1'

    tag "$sample_id"

    input:
    tuple val(sample_id), path(reads)
    path bowtie2_index

    output:
    tuple val(sample_id), file("${sample_id}.sam")

    script:
    """

    # Check if the input FASTQ files exist
     echo "Running Align Reads"
    
    bowtie2 \
    --threads 4 \
    -x ${bowtie2_index}/GRCh38_noalt_as \
    -1 ${reads[0]} \
    -2 ${reads[1]} \
    -S ${sample_id}.sam

    echo "Alignment complete for sample ${sample_id}"
    """
}

process convertSamToBam {
    container 'biocontainers/samtools:v1.15.1_cv2'

    tag "$sample_id"

    input:
    tuple val(sample_id), path(sam_file)

    output:
    tuple val(sample_id), file("${sample_id}.bam")

    script:
    """
    echo "Converting SAM to BAM for sample ${sample_id}"
    
    samtools view -bS ${sample_id}.sam > ${sample_id}.bam

    echo "Conversion complete for sample ${sample_id}"
    rm ${sample_id}.sam
    """
}
    