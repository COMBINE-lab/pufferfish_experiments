#!/bin/bash
#!/usr/bin/env

echo "Pufferfish Experiments"

pufferfish_dir=$(jq -r '.pufferfish_dir' config.json)
echo "pufferfish_dir: $pufferfish_dir"
pufferfish_index_dir=`jq -r '.pufferfish_index_dir' config.json`
echo "pufferfish_index_dir: $pufferfish_index_dir"
read_dir=`jq -r '.read_dir' config.json`
echo "read_dir: $read_dir"
pufferfish_input_dir="."
pufferfish_output_dir=`jq -r '.pufferfish_output_dir' config.json`
echo "pufferfish_output_dir: $pufferfish_output_dir"

datasets=($(jq -r '.datasets[]' config.json))
ranks=($(jq -r '.ranks[]' config.json))


mkdir -p ${pufferfish_output_dir}

mapping_output_dir="${pufferfish_output_dir}/mapping_output"
krakpuff_output_dir="${pufferfish_output_dir}/krakpuff_output"

mkdir -p ${mapping_output_dir}
mkdir -p ${krakpuff_output_dir}

for dataset in "${datasets[@]}"
do
	echo "$dataset"
	/usr/bin/time ${pufferfish_dir}/pufferfish align -i ${pufferfish_index_dir} --read ${read_dir}/${dataset}.fasta -p 16 -m -o ${mapping_output_dir}/${dataset}.dmp --scoreRatio 1.0 -k
	for rank in "${ranks[@]}"
	do
		echo "$rank"
		/usr/bin/time ${pufferfish_dir}/krakmap -t ${pufferfish_input_dir}/nodes.dmp  -s ${pufferfish_input_dir}/seqid2taxid.map -m ${mapping_output_dir}/${dataset}.dmp -o ${krakpuff_output_dir}/${dataset}_${rank}_unfilt.out -l ${rank} -f 0
		/usr/bin/time ${pufferfish_dir}/krakmap -t ${pufferfish_input_dir}/nodes.dmp  -s ${pufferfish_input_dir}/seqid2taxid.map -m ${mapping_output_dir}/${dataset}.dmp -o ${krakpuff_output_dir}/${dataset}_${rank}_44filt.out -l ${rank} -f 44

	done
done
