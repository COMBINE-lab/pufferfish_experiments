#!/bin/bash
#!/usr/bin/env

echo "Clark Experiments"
declare -a datasets=("LC4")

declare -a arrayRank=("phylum")

clark_dir="/home/fatemeh/others_projects/CLARKSCV1.2.4"
clark_db="/mnt/scratch2/avi/meta-map/bin/CLARKSCV1.2.4/db"
clark_read_dir="/mnt/scratch2/avi/meta-map/kraken/reads"
clark_output_dir="/mnt/scratch2/fatemeh/krakpuff/clark_reports/tst"


rm -rf ${clark_output_dir}/input_files
mkdir ${clark_output_dir}/input_files
clark_input_dir=${clark_output_dir}/input_files


for dataset in "${datasets[@]}"
do
	echo ${clark_read_dir}/${dataset}.fasta >> ${clark_input_dir}/reads.txt
done


for rank in "${arrayRank[@]}"
do
	for dataset in "${datasets[@]}"
	do
		echo ${clark_output_dir}/${dataset}_${rank} >> ${clark_input_dir}/dst_${rank}.txt
		echo ${clark_output_dir}/${dataset}_${rank}_filtered >> ${clark_input_dir}/dst_${rank}_filtered.txt
	done
done


cd $clark_dir
echo $pwd
# no filter
echo "NO FILTER ..."
for rank in "${arrayRank[@]}"
do
	echo "${rank}"
	./set_targets.sh ${clark_db} bacteria --${rank}
	/usr/bin/time ./classify_metagenome.sh -n 16 -O ${clark_input_dir}/reads.txt -R  ${clark_input_dir}/dst_${rank}.txt
	for dataset in "${datasets[@]}"
	do
		echo "${dataset}"
		/usr/bin/time ./estimate_abundance.sh -F ${clark_output_dir}/${dataset}_${rank}.csv -D ${clark_db} > ${clark_output_dir}/${dataset}_${rank}.rpt
	done
done


# filtering case
echo "FILTER LOW CCONFIDENCE ..."
for rank in "${arrayRank[@]}"
do
	echo "${rank}"
	./set_targets.sh ${clark_db} bacteria --${rank}
	/usr/bin/time ./classify_metagenome.sh -m 0 -n 16 -O ${clark_input_dir}/reads.txt -R  ${clark_input_dir}/dst_${rank}_filtered.txt
	for dataset in "${datasets[@]}"
	do
		/usr/bin/time ./estimate_abundance.sh -F ${clark_output_dir}/${dataset}_${rank}_filtered.csv -D ${clark_db} --highconfidence > ${clark_output_dir}/${dataset}_${rank}_filtered.rpt
	done
done
