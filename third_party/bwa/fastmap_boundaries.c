#include <zlib.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <ctype.h>
#include <math.h>
#include "bwa.h"
#include "bwamem.h"
#include "kvec.h"
#include "utils.h"
#include "bntseq.h"
#include "kseq.h"
KSEQ_DECLARE(gzFile)

extern unsigned char nst_nt4_table[256];

void *kopen(const char *fn, int *_fd);
int kclose(void *a);
void kt_pipeline(int n_threads, void *(*func)(void*, int, void*), void *shared_data, int n_steps);

typedef struct {
	kseq_t *ks, *ks2;
	mem_opt_t *opt;
	mem_pestat_t *pes0;
	int64_t n_processed;
	int copy_comment, actual_chunk_size;
	bwaidx_t *idx;
} ktp_aux_t;

typedef struct {
	ktp_aux_t *aux;
	int n_seqs;
	bseq1_t *seqs;
} ktp_data_t;

static void *process(void *shared, int step, void *_data)
{
	ktp_aux_t *aux = (ktp_aux_t*)shared;
	ktp_data_t *data = (ktp_data_t*)_data;
	int i;
	if (step == 0) {
		ktp_data_t *ret;
		int64_t size = 0;
		ret = calloc(1, sizeof(ktp_data_t));
		ret->seqs = bseq_read(aux->actual_chunk_size, &ret->n_seqs, aux->ks, aux->ks2);
		if (ret->seqs == 0) {
			free(ret);
			return 0;
		}
		if (!aux->copy_comment)
			for (i = 0; i < ret->n_seqs; ++i) {
				free(ret->seqs[i].comment);
				ret->seqs[i].comment = 0;
			}
		for (i = 0; i < ret->n_seqs; ++i) size += ret->seqs[i].l_seq;
		if (bwa_verbose >= 3)
			fprintf(stderr, "[M::%s] read %d sequences (%ld bp)...\n", __func__, ret->n_seqs, (long)size);
		return ret;
	} else if (step == 1) {
		const mem_opt_t *opt = aux->opt;
		const bwaidx_t *idx = aux->idx;
		if (opt->flag & MEM_F_SMARTPE) {
			bseq1_t *sep[2];
			int n_sep[2];
			mem_opt_t tmp_opt = *opt;
			bseq_classify(data->n_seqs, data->seqs, n_sep, sep);
			if (bwa_verbose >= 3)
				fprintf(stderr, "[M::%s] %d single-end sequences; %d paired-end sequences\n", __func__, n_sep[0], n_sep[1]);
			if (n_sep[0]) {
				tmp_opt.flag &= ~MEM_F_PE;
				mem_process_seqs(&tmp_opt, idx->bwt, idx->bns, idx->pac, aux->n_processed, n_sep[0], sep[0], 0);
				for (i = 0; i < n_sep[0]; ++i)
					data->seqs[sep[0][i].id].sam = sep[0][i].sam;
			}
			if (n_sep[1]) {
				tmp_opt.flag |= MEM_F_PE;
				mem_process_seqs(&tmp_opt, idx->bwt, idx->bns, idx->pac, aux->n_processed + n_sep[0], n_sep[1], sep[1], aux->pes0);
				for (i = 0; i < n_sep[1]; ++i)
					data->seqs[sep[1][i].id].sam = sep[1][i].sam;
			}
			free(sep[0]); free(sep[1]);
		} else mem_process_seqs(opt, idx->bwt, idx->bns, idx->pac, aux->n_processed, data->n_seqs, data->seqs, aux->pes0);
		aux->n_processed += data->n_seqs;
		return data;
	} else if (step == 2) {
		for (i = 0; i < data->n_seqs; ++i) {
			if (data->seqs[i].sam) err_fputs(data->seqs[i].sam, stdout);
			free(data->seqs[i].name); free(data->seqs[i].comment);
			free(data->seqs[i].seq); free(data->seqs[i].qual); free(data->seqs[i].sam);
		}
		free(data->seqs); free(data);
		return 0;
	}
	return 0;
}

static void update_a(mem_opt_t *opt, const mem_opt_t *opt0)
{
	if (opt0->a) { // matching score is changed
		if (!opt0->b) opt->b *= opt->a;
		if (!opt0->T) opt->T *= opt->a;
		if (!opt0->o_del) opt->o_del *= opt->a;
		if (!opt0->e_del) opt->e_del *= opt->a;
		if (!opt0->o_ins) opt->o_ins *= opt->a;
		if (!opt0->e_ins) opt->e_ins *= opt->a;
		if (!opt0->zdrop) opt->zdrop *= opt->a;
		if (!opt0->pen_clip5) opt->pen_clip5 *= opt->a;
		if (!opt0->pen_clip3) opt->pen_clip3 *= opt->a;
		if (!opt0->pen_unpaired) opt->pen_unpaired *= opt->a;
	}
}

int main_fastmap_boundaries(int argc, char *argv[])
{
	int c, i, j, jj, min_iwidth = 20, min_len = 17, print_seq = 0, min_intv = 1, max_len = INT_MAX;
	uint64_t max_intv = 0;
    long foundKmer = 0 ;
    long notFound = 0 ;
    long rightPos = 0 ;
    long wrongPos = 0 ;
    long kmers = 0 ;
    long totalHits = 0 ;
    int num_n = 0;
    int next_n = 0;
    int seen_n = 0;
    int npos[255];

#define bool int
#define true 1
#define false 0
#define KMER_SZ 31


	kseq_t *seq;
	bwtint_t k;
	gzFile fp;
	smem_i *itr;
	const bwtintv_v *a;
	bwaidx_t *idx;

	while ((c = getopt(argc, argv, "w:l:pi:I:L:")) >= 0) {
		switch (c) {
			case 'p': print_seq = 1; break;
			case 'w': min_iwidth = atoi(optarg); break;
			case 'l': min_len = atoi(optarg); break;
			case 'i': min_intv = atoi(optarg); break;
			case 'I': max_intv = atol(optarg); break;
			case 'L': max_len  = atoi(optarg); break;
		    default: return 1;
		}
	}
	if (optind + 1 >= argc) {
		fprintf(stderr, "\n");
		fprintf(stderr, "Usage:   bwa fastmap [options] <idxbase> <in.fq>\n\n");
		fprintf(stderr, "Options: -l INT    min SMEM length to output [%d]\n", min_len);
		fprintf(stderr, "         -w INT    max interval size to find coordiantes [%d]\n", min_iwidth);
		fprintf(stderr, "         -i INT    min SMEM interval size [%d]\n", min_intv);
		fprintf(stderr, "         -L INT    max MEM length [%d]\n", max_len);
		fprintf(stderr, "         -I INT    stop if MEM is longer than -l with a size less than INT [%ld]\n", (long)max_intv);
		fprintf(stderr, "\n");
		return 1;
	}

	fp = xzopen(argv[optind + 1], "r");
	seq = kseq_init(fp);
	if ((idx = bwa_idx_load(argv[optind], BWA_IDX_BWT|BWA_IDX_BNS)) == 0) return 1;
	itr = smem_itr_init(idx->bwt);
	smem_config(itr, min_intv, max_len, max_intv);
	while (kseq_read(seq) >= 0) {
		long realPos = 1 ;

		//err_printf("SQ\t%s\t%ld", seq->name.s, seq->seq.l);
		if (print_seq) {
			//err_putchar('\t');
			//err_puts(seq->seq.s);
		} else {//err_putchar('\n');
		}
		//char kmer[KMER_SZ];
		//char* rseq = (char*)malloc(seq->seq.l);
		//strcpy(rseq, seq->seq.s);

    // Convert to bwa-encoding
    num_n = 0;
    next_n = 0;
    seen_n = 0;
		for (i = 0; i < seq->seq.l; ++i) {
      if ((char)seq->seq.s[i] == 'n' || (char)seq->seq.s[i] == 'N') {
        npos[num_n] = i;
        ++num_n;
      }
			seq->seq.s[i] = nst_nt4_table[(int)seq->seq.s[i]];
    }
    // For each k-mer in this read
		for(j = 0; j < seq->seq.l - KMER_SZ+1 ; ++j){
			++kmers ;
			if(kmers% 1000000 == 0){
				err_printf("kmers processed :[%ld]\n",kmers) ;
			}
			//smem_set_query(itr, KMER_SZ , (uint8_t*)kmerArray[j][0].s);

      // If there are 'N's remaining in the read, then check if the current
      // k-mer overlaps the next one.  If so, move to the first k-mer past
      // that 'N'.
      while (seen_n < num_n && npos[seen_n] < j + KMER_SZ) {
        j = npos[seen_n] + 1;
        ++seen_n;
      }
      if (j >= seq->seq.l - KMER_SZ+1) { break; }

			smem_set_query(itr, KMER_SZ , (uint8_t*)(&seq->seq.s[j]));
			realPos = j+1 ;
			//bool found = false;
			// there should be at most 1 smem (i.e., the k-mer) found.
			//bool first_smem = true;
			//while ((a = smem_next(itr)) != 0 && first_smem) {
			if ((a = smem_next(itr)) != 0 && a->n > 0) {
				//first_smem = false;
					long thisHit = 0;
					bool kmerSeen = 0;
					for (i = 0; i < a->n; ++i) {
						//printf("found kmer at position %d  in the read\n", realPos);
						bwtintv_t *p = &a->a[i];
						bwtint_t pos;
						int len, is_rev, ref_id;
						len  = (uint32_t)p->info - (p->info>>32);
						if (len < KMER_SZ)
							continue;
						long boundary_cntr = 0;
            for (k = 0; k < p->x[2]; ++k) {
							bwtint_t pos;
							int is_rev, ref_id;
              // get the reference position associated with this hit
							pos = bns_depos(idx->bns, bwt_sa(idx->bwt, p->x[0] + k), &is_rev);
              // if it's in the RC direction, correct the "start" position to
              // be the leftmost position.
							if (is_rev) pos -= len - 1;
							ref_id = bns_pos2rid(idx->bns, pos);
							if (idx->bns->anns[ref_id].len < pos-idx->bns->anns[ref_id].offset + KMER_SZ)
								boundary_cntr+=1;
						}
						//err_printf("\thits:%ld , boundaries:%ld\n", (long)p->x[2], boundary_cntr);
						thisHit = (long)(p->x[2])-boundary_cntr ;
						//pos = bns_depos(idx->bns, bwt_sa(idx->bwt, p->x[0] + k), &is_rev);
						//if (is_rev) pos -= len - 1;
						//bns_cnt_ambi(idx->bns, pos, len, &ref_id);
						//if(strcmp(seq->name.s, idx->bns->anns[ref_id].name) == 0 && realPos != (long)(pos - idx->bns->anns[ref_id].offset)+1 && !found){
						//err_printf("\t%s:%c%ld\t%ld\t%ld\n", idx->bns->anns[ref_id].name, "+-"[is_rev], (long)(pos - idx->bns->anns[ref_id].offset) + 1, realPos, len);
						//for (int k = 0; k < KMER_SZ; ++k) {
						//		kmer[k] = rseq[j+k];
						//}
						//err_printf("\t%s\n", kmer);
					//}

					//totalHits += (long)(a->n) ;
					if(thisHit > 0){
						foundKmer++ ;
						totalHits += thisHit;
						//for (int k = 0; k < KMER_SZ; ++k) {
						//	kmer[k] = rseq[j+k];//seq->seq.s[j+k];
						//}
						//err_printf("\t%s\n", kmer);
					} else{
						notFound++ ;
					}
					kmerSeen = 1;
					break;
			}
			if (!kmerSeen) {++notFound;}
			}

		}
		//err_puts("//");
	}

    err_printf("\tfoundKmers = %ld\n",foundKmer) ;
    err_printf("\tnotFound kmers = %ld\n",notFound) ;
    err_printf("\ttotal hits = %ld\n",totalHits) ;
    //err_printf("\tRight Pos = %ld\n",rightPos) ;
    //err_printf("\tWrong Pos = %ld\n",wrongPos) ;

	smem_itr_destroy(itr);
	bwa_idx_destroy(idx);
	kseq_destroy(seq);
	err_gzclose(fp);
	return 0;
}
