#!/usr/bin/env bash

show_help() {
    echo "Usage:

    ${0##*/} [-h][-o OUTPUT_DIRECTORY][-v]

Options:

  -h
     display the help message
  -o
     the directory where the downloaded files should be written (will be created if it doesn't exist)
  -v
     be verbose and print what we are doing
  "
}

## parsing code from : https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
output_dir=""
verbose=0

while getopts "h?vo:" opt; do
    case "$opt" in
        h|\?)
            show_help
            exit 0
            ;;
        v)  verbose=1
            ;;
        o)  output_dir=$OPTARG
            ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

if [[ -z "${output_dir// }" ]]; then
    echo "You must provide an output directory for the downloaded files."
    exit 1
fi

if [ $verbose == 1 ]; then
    echo "Creating output directory ${output_dir} if it doesn't yet exist"
fi

mkdir -p ${output_dir}

# get the files
if [ $verbose == 1 ]; then
    echo "Downloading transcriptome and writing it to ${output_dir}/gencode.v25.pc_transcripts_fixed.fa"
fi
curl -o ${output_dir}/gencode.v25.pc_transcripts_fixed.fa https://zenodo.org/record/995689/files/gencode.v25.pc_transcripts_fixed.fa

if [ $verbose == 1 ]; then
    echo "Downloading transcriptome and writing it to ${output_dir}/GRCh38.primary_assembly.genome.fixed.fa"
fi
curl -o ${output_dir}/GRCh38.primary_assembly.genome.fixed.fa https://zenodo.org/record/995689/files/GRCh38.primary_assembly.genome.fixed.fa

if [ $verbose == 1 ]; then
    echo "Downloading transcriptome and writing it to ${output_dir}/bacterial.genome.fixed.fa"
fi
curl -o ${output_dir}/bacterial.genome.fixed.fa https://zenodo.org/record/995689/files/bacterial.genome.fixed.fa

if [ $verbose == 1 ]; then
    echo "All files have been downloaded."
fi
