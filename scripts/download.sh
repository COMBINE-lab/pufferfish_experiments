# get list of available bacterial genome assemblies in RefSeq
DOMAIN=bacteria
wget --quiet -nc ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/$DOMAIN/assembly_summary.txt -O assembly_summary_$DOMAIN.txt
# Get FTP path (column 20) for assemblies at the level "Complete Genome" (column 12) and "latest" version_status (column 11)
awk -F "\t" '($12=="Complete Genome" || $12=="Chromosome") && $11=="latest"{print $6" "$20}' assembly_summary_$DOMAIN.txt > ftpdirpaths_$DOMAIN
# Download all the genomic.fna files
cat ftpdirpaths_$DOMAIN | parallel --bar --gnu -j 20 "wget -nc --quiet --directory-prefix=. {}/*.fna.gz"
