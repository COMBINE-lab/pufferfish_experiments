#!/bin/bash
#!/usr/bin/env

echo "Kraken Experiments"
declare -a datasets=("LC4")
declare -a ranks=("phylum")

kraken_dir="/home/fatemeh/others_projects/kraken_installed"
kraken_db="/mnt/scratch2/avi/meta-map/kraken/KrakenDB"
kraken_read_dir="/mnt/scratch2/avi/meta-map/kraken/reads"
kraken_output_dir="/mnt/scratch2/fatemeh/krakpuff/kraken/tst"

mkdir -p ${kraken_output_dir}

for dataset in "${datasets[@]}"
do
	echo $dataset
	echo "unfiltered"
#/usr/bin/time ${kraken_dir}/kraken --db ${kraken_db} --threads 16 --fasta-input ${kraken_read_dir}/${dataset}.fasta > ${kraken_output_dir}/${dataset}_unfilt.krk

#/usr/bin/time ${kraken_dir}/kraken-report --db ${kraken_db} ${kraken_output_dir}/${dataset}_unfilt.krk > ${kraken_output_dir}/${dataset}_unfilt.rpt

	echo "20% filtered"
	/usr/bin/time ${kraken_dir}/kraken-filter --db ${kraken_db} ${kraken_output_dir}/${dataset}_unfilt.krk --threshold 0.2 > ${kraken_output_dir}/${dataset}_filt0_2.krk

	/usr/bin/time ${kraken_dir}/kraken-report --db ${kraken_db} ${kraken_output_dir}/${dataset}_filt0_2.krk > ${kraken_output_dir}/${dataset}_filt0_2.rpt
done
