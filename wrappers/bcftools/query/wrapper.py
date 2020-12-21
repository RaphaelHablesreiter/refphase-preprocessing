__author__ = "Raphael Hablesreiter"
__copyright__ = "Copyright 2020, Raphael Hablesreiter"
__email__ = "raphael.hablesreiter@icloud.com"
__license__ = "MIT"


from snakemake.shell import shell

shell(
    "bcftools query {snakemake.params} {snakemake.input[0]} | bgzip -c > {snakemake.output[0]}"
)
