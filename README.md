# Experiments for the pufferfish paper
This repository provides access to all the datasets and commands needed to run the experiments explained in the [pre-print for pufferfish](https://www.biorxiv.org/content/early/2017/09/21/191874).

## Workflow Setting
We used [Snakemake](http://snakemake.readthedocs.io/en/stable/) to manage the workflow used to run all experiments. Therefore, you just need to obtain the necesary pre-requisite files (as described below) and setup the necessary configurations (such as links to the input files and binaries of the required tools) and run snakemake on the snakefile provided here. The Snakefile (**"Snakefile"**) along with the config file (**"config.json"**) in this repository contain all the commands and information to run three pipelines of **BWA**, **Kallisto**, and **Pufferfish** on three datasets of **human transcriptome**, **human genome**, and **bacterial genomes**.

As explained in the [pufferfish pre-print](https://www.biorxiv.org/content/early/2017/09/21/191874), to unify all the pipelines of different tools, we needed provide simple "lookup" methods for "BWA" and "kallisto". The relevant source code that provides this functionality has been committed to this repository under the subdirectory `third_party`. all the related experiments for BWA and kallisto have been run using the binaries constructed from the updated source codes. So, user needs to make the binaries for BWA and Kallisto in the third_party and later set the required address in the config file to link to them.

### Making dependent binaries

To make the relevant version of BWA, execute the following commands from the top level of this repository:

```
$ cd third_party/bwa
$ make
$ cd ../..
```

If there were no problems running `make`, you should have an executable named `bwa` in `third_party/bwa`.  Now, we need to build `kallisto`; this can be done with the following commands:

```
$ cd third_party/kallisto_kmer_lookup
$ mkdir build
$ cd build
$ cmake ..
$ make
$ cd ../../..
```

That is, we descend into the directory for kallisto, make a directory called `build`, move into that directory and configure the build with the command `cmake ..`, and then build the actual executable with the command `make`.  If these steps were succesful, then you should have an executable named `kallisto` in the directory `third_party/kallisto_kmer_lookup/build/src`.

We also require two other tools to run our pipeline; [TwoPaCo](https://github.com/medvedevgroup/TwoPaCo) for building the compacted de Bruijn graph on input reference genomes and [pufferfish](https://github.com/COMBINE-lab/pufferfish) (our tool for compacted colored de Bruijn graph indexing and query).  We use the standard versions of both of these tools, and instructions for building these tools can be found on the respective GitHub pages.

## Config file
Config file contains the addresses to the following information:
1. value of k for k-mer based indexing tools (Kallisto and Pufferfish), default is **31**.
2. Address to all the binary files for "BWA", "Kallisto", "TwoPaCo", and "Pufferfish". For kallisto and BWA, it is already set to the adopted versions in "third_party/bwa/bwa" and "third_party/kallisto_kmer_lookup/build/src/kallisto".
3. Directory where all the input Datasets are stored.
4. Directory of the output results (e.g. the indices and some intermediate files that will be removed at the end of the process.)
5. Name of the reference and read files.

Therefore before running the snakemake command, the user should first set all these information in the config file.
## Datasets
To run all the experiments, you need a reference and a sequence read sample for each of the datasets.
### References:
The reference fasta files used for pufferfish pre-print experiments are all uploaded to [zenodo](https://zenodo.org/record/995689#.WcgMz0pSy8o).  You can use the included script `fetch_refs.sh` to download them easily.  First, choose a location where you want the downloaded references to be stored (these files will require ~22G of space in total).  Then, execute the script like so:

```
$ bash fetch_refs.sh -o <OUTPUT_DIR>
```

the script will create the output directory `<OUTPUT_DIR>` if it doesn't already exist.  If you want to see what the script is doing, you can use the verbose flag `-v` as well.

### Sequenced Reads:
For each of the three experiments on human transcritpme, human genome, and bacterial genomes we use the SRA accessions "SRR1215997", "SRR5833294", and "SRR5901135" respectively.

After downloading the corresponding files for these three experiments, you should either update the "config.json" file and change the corresponding name for each data set or change the downloaded data file name as following:
1. "SRR1215997" to *human_txome_reads.fa*
2. "SRR5833294" to *human_genome_reads.fa*
3. "SRR5901135" to *bacterial_genome_reads.fa*

## Run the Pipeline
After setting all the configs and downloading the datasets, you can run the experiments by running the following snakemake command in the root directory of this repository:

```
$ snakemake --configfile config.json 
```

The version of snakemake we ran all the experiments with is **3.13.3**.
