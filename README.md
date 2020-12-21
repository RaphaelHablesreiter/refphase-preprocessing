# Preprocessing Snakemake workflow for refphase

A simple Snakemake workflow that helps to create the input needed for [refphase](https://bitbucket.org/schwarzlab/refphase/src/master/).

## Input:
* BAM-files of NORMAL and TUMOR with removed duplicates (*e.g.,* picard MarkDuplicates)
* reference genome 
* BED-file of targeted regions

## Output:
* Pileups for each sample at positions of germline variants
