#!/bin/bash
#!/usr/bin/env

echo "Kraken Experiments"
declare -a datasets=("LC4")
declare -a ranks=("phylum")

kraken_read_dir=`jq -r '.read_dir' config.json`
echo "read_dir: $kraken_read_dir"
kraken_dir=`jq -r '.kraken_dir' config.json`
echo "kraken_dir: $kraken_dir"
kraken_db=`jq -r '.kraken_db' config.json`
echo "kraken_db: $kraken_db"
kraken_output_dir=`jq -r '.kraken_output_dir' config.json`
echo "kraken_output_dir: $kraken_output_dir"

mkdir -p ${kraken_output_dir}

for dataset in "${datasets[@]}"
do
	echo $dataset
	echo "unfiltered"
	/usr/bin/time ${kraken_dir}/kraken --db ${kraken_db} --threads 16 --fasta-input ${kraken_read_dir}/${dataset}.fasta > ${kraken_output_dir}/${dataset}_unfilt.krk

	/usr/bin/time ${kraken_dir}/kraken-report --db ${kraken_db} ${kraken_output_dir}/${dataset}_unfilt.krk > ${kraken_output_dir}/${dataset}_unfilt.rpt

	echo "20% filtered"
	/usr/bin/time ${kraken_dir}/kraken-filter --db ${kraken_db} ${kraken_output_dir}/${dataset}_unfilt.krk --threshold 0.2 > ${kraken_output_dir}/${dataset}_filt0_2.krk

	/usr/bin/time ${kraken_dir}/kraken-report --db ${kraken_db} ${kraken_output_dir}/${dataset}_filt0_2.krk > ${kraken_output_dir}/${dataset}_filt0_2.rpt
done
