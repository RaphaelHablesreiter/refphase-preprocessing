# ==============================================================================
# Snakefile
#
# Author: Raphael Hablesreiter (raphael.hablesreiter@charite.de)
#
# Adapted from Matt Huska (AG Schwarz - MDC Berlin)
#
# Description:
# General refphase preprocessing workflow for detecting SCNA in tumor samples.
# See https://bitbucket.org/schwarzlab/refphase/src/master/for further details.
# BAM-files should have duplicates removed.
# 
# Input: 
#  -bam-files: {samples}_{timepoints}.processed.bam 
#  -reference-files: refs/genome.fasta, refs/genome.fasta.fai, refs/genome.dict
#  -target regions: refs/targets.bed
# ==============================================================================


import os

# insert samples
samples=["Sample1", "Sample2"]

# insert timepoints --> normal==CR1
timepoints=["CR1", "Rel1", "D"]

rule all:
    input:
        expand("results/{sample}-{type}.pos.gz", sample = samples, type = timepoints)

rule bcftools_mpileup_germline:
    input:
        index="refs/genome.fasta.fai",
        ref="refs/genome.fasta", # this can be left out if --no-reference is in options
        alignments="input/{sample}_CR1.processed.bam",
    output:
        pileup="pileups/{sample}-germline.pileup.bcf",
    params:
        options="-R refs/targets.bed",
    log:
        "logs/bcftools_mpileup/{sample}.log",
    wrapper:
        "0.64.0/bio/bcftools/mpileup"

rule bcftools_call_germline:
    input:
        pileup="pileups/{sample}-germline.pileup.bcf",
    output:
        calls="germlinepos/{sample}-germline.calls.bcf",
    params:
        caller="-m", # valid options include -c/--consensus-caller or -m/--multiallelic-caller
        options="-v -Ob",
    log:
        "logs/bcftools_call/{sample}-germline.log",
    wrapper:
        "0.64.0/bio/bcftools/call"        

rule bcftools_query_germline:
    input:
        "germlinepos/{sample}-germline.calls.bcf"
    output:
        "germlinepos/{sample}.pos.gz"
    params:
        extra="--format '%CHROM\t%POS\n'"  # optional parameters for bcftools query (except -o)
    wrapper:
        "file:wrappers/bcftools/query"

rule bcftools_mpileup_samples:
    input:
        index="refs/genome.fasta.fai",
        ref="refs/genome.fasta", # this can be left out if --no-reference is in options
        alignments="input/{sample}_{type}.processed.bam",
        germlinepos="germlinepos/{sample}.pos.gz",
    output:
        pileup="results/{sample}-{type}.pileup.bcf",
    params:
        options="--regions-file germlinepos/{sample}.pos.gz --annotate FORMAT/AD",
    log:
        "logs/bcftools_mpileup/{sample}-{type}.log",
    wrapper:
        "0.64.0/bio/bcftools/mpileup"

rule bcftools_query_samples:
    input:
        "results/{sample}-{type}.pileup.bcf"
    output:
        "results/{sample}-{type}.pos.gz"
    params:
        lambda wc: "--format \"%CHROM\\t%POS\\t[%AD{0}]\\t[%AD{1}]\\n\""  # optional parameters for bcftools query (except -o)
    wrapper:
        "file:wrappers/bcftools/query"


