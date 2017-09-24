# Experiments for the pufferfish paper

## Get reference data:
The reference fasta files used for pufferfish pre-print experiments are all uploaded to [zenodo](https://zenodo.org/record/995689#.WcgMz0pSy8o).  You can use the included script `fetch_refs.sh` to download them easily.  First, choose a location where you want the downloaded references to be stored (these files will require ~22G of space in total).  Then, execute the script like so:

```
$ bash fetch_refs.sh -o <OUTPUT_DIR>
```

the script will create the output directory `<OUTPUT_DIR>` if it doesn't already exist.  If you want to see what the script is doing, you can use the verbose flag `-v` as well.
