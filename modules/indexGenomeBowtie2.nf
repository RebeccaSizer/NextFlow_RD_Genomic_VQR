/*
 * Define the indexGenome process that creates a Bowtie2 index
 * given the genome fasta file
 */
process indexGenomeBowtie2 {

    container 'biocontainers/bowtie2:v2.4.1_cv1'

    publishDir("$params.outdir/GENOME_IDX", mode: "copy")

    input:
    path genomeFasta

    output:
    tuple path(genomeFasta), path("${genomeFasta.baseName}.*")

    script:
    """
    echo "Running Index Genome"

    indexPrefix=\$(basename ${genomeFasta} .fasta)

    bowtie2-build "${genomeFasta}" "\$indexPrefix"

    echo "Genome Indexing complete."
    """
}