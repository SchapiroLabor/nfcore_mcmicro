process ROADIE_RECYZE {
    tag "$meta.id"
    label 'process_single'

    container "ghcr.io/labsyspharm/mcmicro:roadie-2023-10-25"

    input:
    tuple val(meta), path(image)
    val(channels)

    output:
    tuple val(meta), path("*.tif"), emit: extracted_channels
    path "versions.yml"           , emit: versions

    script:
    def args   = task.ext.args   ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def channels_str = channels.join(' ')

    """
    recyze.py \\
        --in ${image} \\
        --out ${prefix}.tif \\
        --channels ${channels_str} \\
        --num-threads $task.cpus \\
        $args \\

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        recyze: \$(recyze.py --version)
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    // TODO nf-core: A stub section should mimic the execution of the original module as best as possible
    //               Have a look at the following examples:
    //               Simple example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bcftools/annotate/main.nf#L47-L63
    //               Complex example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bedtools/split/main.nf#L38-L54
    """
    touch ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        roadie: \$(samtools --version |& sed '1!d ; s/samtools //')
    END_VERSIONS
    """
}
