INFILENAME=$1
K=$2
#OUTFILENAME=$1$3
#head -$NUMSEQS $INFILENAME.fa > $OUTFILENAME.fa
if [ ! -z $3 ]
	then 
		NUMSEQS=$(($3*2)) 
		head -$NUMSEQS $INFILENAME.fa > $INFILENAME.s$3.fa
		INFILENAME=$INFILENAME.s$3
fi
OUTFILENAME=$INFILENAME.k$K
echo $OUTFILENAME
/home/fatemeh/projects/TwoPaCo/build/graphconstructor/twopaco -k $K -t 8 -f 32 $INFILENAME.fa --outfile dee.bin
/home/fatemeh/projects/TwoPaCo/build/graphdump/graphdump dee.bin -f gfa1 -k $K -s $INFILENAME.fa > $OUTFILENAME.gfa
/home/fatemeh/pufferfish/build/src/pufferize -k $K -g $OUTFILENAME.gfa -f $INFILENAME.fa -o $OUTFILENAME.pufferized.gfa
