# Taxonomic Read Assignment Experiments

### Requirements:
**jq**

Downloading/installing instructions can be found [here](https://stedolan.github.io/jq/download/)
If you use *Debian* or *Ubuntu* distributions of linux, you can install using `apt-get`.

```
$ sudo apt-get install jq
````
### Assumptions:
Name of the read files should be in the format of `dataset.fasta` where list of datasets
are given as a variable in *config.json* file.


### Running Instructions:
1. Run the *index building* step of all three tools **Kraken**, **Clark**, and **Pufferfish**.

2. Set variables in *config.json* to the correct values (i.e. paths to the read direcotry, binary file, index and output directory for each tool, and list of read datasets).

3. Run **bash \*_commands.sh** for generating reports for any of the tools


