process ROADIE_RECYZE {
    tag "$meta.id"
    label 'process_single'

    container "ghcr.io/labsyspharm/mcmicro:roadie-2023-10-25"

    input:
    tuple val(meta), path(image)
    val(channels)
    val(nuclear_channels)
    val(membrane_channels)

    output:
    tuple val(meta), path("*_stack.tif")   , emit: extracted_channels
    tuple val(meta), path("*_nuclear.tif") , emit: nuclear_single_channel , optional: true
    tuple val(meta), path("*_membrane.tif"), emit: membrane_single_channel, optional: true
    path "versions.yml"                    , emit: versions

    script:
    def args         = task.ext.args   ?: ''
    def prefix       = task.ext.prefix ?: "${meta.id}"
    def channels_str = channels.join(' ')
    def nuclear_channels_command = nuclear_channels ? " --nuclear_channels ${nuclear_channels.join(' ')}" : ''
    def membrane_channels_command = membrane_channels ? " --membrane_channels ${membrane_channels.join(' ')}" : ''

    """
    recyze.py \\
        --in ${image} \\
        --out ${prefix}_stack.tif \\
        --channels ${channels_str} \\
        ${nuclear_channels_command} \\
        ${membrane_channels_command} \\
        --num-threads $task.cpus \\
        --nuclear_out ${prefix}_nuclear.tif \\
        --membrane_out ${prefix}_membrane.tif \\
        $args \\

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        recyze: \$(recyze.py --version)
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_stack.tif
    touch ${prefix}_nuclear.tif
    touch ${prefix}_membrane.tif

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        roadie: \$(recyze.py --version)
    END_VERSIONS
    """
}
