/*
 * Use DeepVariant to call variants from the aligned reads in the BAM file.
 * This process takes the sample ID, BAM file, BAM index, and the genome index files as input,
 * and produces a VCF file with the called variants and its index as output.
 */

process deepVariant {
    
    tag "$bamFile"

    container 'google/deepvariant:1.4.0'

    input:
    tuple val(sample_id), file(bamFile), file(bamIndex)
    path indexFiles

    output:
    tuple val(sample_id), file("*.vcf")

    script:
    """

    echo "Running DeepVariant for Sample: ${bamFile}"

    if [[ -n ${params.genome_file} ]]; then
        genomeFasta=\$(basename ${params.genome_file})
    else
        genomeFasta=\$(find -L . -name '*.fasta')
    fi

    echo "Genome File: \${genomeFasta}"

    # Rename the dictionary file to the expected name if it exists
    if [[ -e "\${genomeFasta}.dict" ]]; then
        mv "\${genomeFasta}.dict" "\${genomeFasta%.*}.dict"
    fi

    outputVcf="\$(basename ${bamFile} _sorted_dedup_recalibrated.bam).vcf"

    # Use DeepVariant to call variants with specified annotations 
    /opt/deepvariant/bin/run_deepvariant \
        --model_type=WES \
        --ref="\${genomeFasta}" \
        --reads="${bamFile}" \
        --output_vcf="\${outputVcf}" \
        --num_shards=16 \
        --vcf_stats_report=true \

    echo "Sample: ${sample_id} VCF: \${outputVcf}"

    echo "VCF stats report generated" > stats_report.txt

    echo "Variant Calling for Sample: ${sample_id} Complete"
    """
}

process indexBam {

    tag "$IndexVCF"

    container 'bcftools/bcftools:1.15.1'

    input:
    tuple val(sample_id), path(IndexVCF)

    output:
    tuple val(sample_id), file("${sample_id}.vcf.gz"), file("${sample_id}.vcf.gz.tbi")

    script:
    """
    echo "Indexing VCF for Sample: ${sample_id}"

    bcftools view -Oz "${IndexVCF}" -o "${sample_id}.vcf.gz"
    bcftools index "${sample_id}.vcf.gz"
    echo "Indexing complete for Sample: ${sample_id}"
    """

}