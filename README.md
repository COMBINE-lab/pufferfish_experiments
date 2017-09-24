# Experiments for the pufferfish paper

To run all the experiments, you need the reference and a sequence read sample for three data sets of *human transcriptome*, *human genome*, and *8k bacterial genomes*.
## References:
The reference fasta files used for pufferfish pre-print experiments are all uploaded to [zenodo](https://zenodo.org/record/995689#.WcgMz0pSy8o).  You can use the included script `fetch_refs.sh` to download them easily.  First, choose a location where you want the downloaded references to be stored (these files will require ~22G of space in total).  Then, execute the script like so:

```
$ bash fetch_refs.sh -o <OUTPUT_DIR>
```

the script will create the output directory `<OUTPUT_DIR>` if it doesn't already exist.  If you want to see what the script is doing, you can use the verbose flag `-v` as well.

## Sequenced Reads:
For each of the three experiments on human transcritpme, human genome, and bacterial genomes we use the SRA accessions "SRR1215997", "SRR5833294", and "SRR5901135" respectively.

After downloading the corresponding files for these three experiments, you should either update the "config.json" file and change the corresponding name for each data set or change the downloaded data file name as following:
1. "SRR1215997" to *human_txome_reads.fa*
2. "SRR5833294" to *human_genome_reads.fa*
3. "SRR5901135" to *bacterial_genome_reads.fa*


