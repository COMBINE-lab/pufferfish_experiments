import gzip
import os
import argparse
import glob
import tqdm



parser = argparse.ArgumentParser(description="creares concatenated fasta file from samples")
parser.add_argument('-d', '--dir',type=str, dest="d" ,help="Input folder that contains the gzipped fasta files")
parser.add_argument('-o', '--output',type=str, dest="o" ,help="output fasta file")
parser.add_argument('-s', '--sampleSize',type = int, dest="s" ,help="number of genomes to be concatenated")

args = parser.parse_args()

out_handle=open(args.o,"w")

i=1
for f in tqdm.tqdm(glob.glob(args.d+"/*.gz")):
    seq_idx=1
    seq_name=f.split("/")[-1].split(".")[0]
    with gzip.open(f, 'rb') as h:
        for line in h.readlines():
            if line[0]==">":
                out_handle.write(">%s_%d\n"%(seq_name,seq_idx))
                seq_idx+=1
                continue
            out_handle.write(line)
    i+=1
    if(i == args.s+1):
        break
