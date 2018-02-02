pufferfish_dir="/home/fatemeh/projects/pufferfish/build/src"
pufferfish_index_dir="/mnt/scratch2/avi/meta-map/kraken/puff/index"
read_dir="/mnt/scratch2/avi/meta-map/kraken/reads"
pufferfish_input_dir="."
pufferfish_output_dir="/mnt/scratch2/fatemeh/krakpuff"

declare -a datasets="(LC4)"
declare -a ranks=("phylum")

mapping_output_dir=${pufferfish_output_dir}"/mapping_output"
krakpuff_output_dir=${pufferfish_output_dir}"/krakpuff_output"

mkdir -p ${mapping_output_dir}
mkdir -p ${krakpuff_output_dir}

for dataset in "${datasets[@]}"
do
	/usr/bin/time ${pufferfish_dir}/pufferfish align -i ${pufferfish_index_dir} --read ${read_dir}/${dataset}.fasta -p 16 -m -o ${mapping_output_dir}/${dataset}.dmp --scoreRatio 1.0 -k
	for rank in "${ranks[@]}"
	do
		/usr/bin/time ${pufferfish_dir}/krakmap -t ${pufferfish_input_dir}/nodes.dmp  -s ${pufferfish_input_dir}/seqid2taxid.map -m ${mapping_output_dir}/${dataset}.dmp -o ${krakpuff_output_dir}/${dataset}_${rank}_unfilt.out -l ${rank} -f 0
		/usr/bin/time ${pufferfish_dir}/krakmap -t ${pufferfish_input_dir}/nodes.dmp  -s ${pufferfish_input_dir}/seqid2taxid.map -m ${mapping_output_dir}/${dataset}.dmp -o ${krakpuff_output_dir}/${dataset}_${rank}_44filt.out -l ${rank} -f 44

	done
done
