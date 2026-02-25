/*
 * Define the indexGenome process that creates a BWA index
 * given the genome fasta file
 */
process indexGenomeBowtie2 {

    if (params.platform == 'local') {
        label 'process_low'
    } else if (params.platform == 'cloud') {
        label 'process_medium'
    }
    
    container 'biocontainers/bowtie2:v2.4.1_cv1'


    // Publish indexed files to the specified directory
    publishDir("$params.outdir/GENOME_IDX", mode: "copy")

    input:
    path genomeFasta

    output:
    tuple path(genomeFasta), path("${genomeFasta.baseName}_bowtie2.*")

    script:
    """
    echo "Running Index Genome"

    # Define index prefix based on fasta filename
    indexPrefix=\$(basename ${genomeFasta} .fasta)_bowtie2

    # Generate BWA index
    bowtie2-build "${genomeFasta}" "\$indexPrefix"

    echo "Genome Indexing complete."
    """
}