#ifndef KALLISTO_KMERINDEX_H
#define KALLISTO_KMERINDEX_H


#include <iostream>
#include <fstream>
#include <vector>
#include <unordered_map>
#include <stdint.h>
#include <ostream>
//#include <map>

#include "core/range.hpp"
#include "common.h"
#include "Kmer.hpp"
#include "KmerIterator.hpp"

#include "KmerHashTable.h"

#include "hash.hpp"

std::string revcomp(const std::string s);


struct TRInfo {
  int trid;
  int start;
  int stop; //exclusive [start,stop)
  bool sense; // true for sense, false for anti-sense
};

using EcMap = std::vector<std::vector<int>>; //std::unordered_map<int, std::vector<int>>;

struct SortedVectorHasher {
  size_t operator()(const std::vector<int>& v) const {
    uint64_t r = 0;
    int i=0;
    for (auto x : v) {
      uint64_t t;
      MurmurHash3_x64_64(&x,sizeof(x), 0,&t);
      t = (x>>i) | (x<<(64-i));
      r = r ^ t;
      i = (i+1)%64;
    }
    return r;
  }
};

struct KmerEntry {
  int32_t contig; // id of contig
  uint32_t _pos; // 0-based forward distance to EC-junction
  int32_t contig_length;

  KmerEntry() : contig(-1), _pos(0xFFFFFFF), contig_length(0) {}
  KmerEntry(int id, int length, int pos, bool isFw) : contig(id), contig_length(length) {
    setPos(pos);
    setDir(isFw);
  }

  inline int getPos() const {return (_pos & 0x0FFFFFFF);}
  inline int isFw() const  {return (_pos & 0xF0000000) == 0; }
  inline void setPos(int p) {_pos = (_pos & 0xF0000000) | (p & 0x0FFFFFFF);}
  inline void setDir(bool _isFw) {_pos = (_pos & 0x0FFFFFFF) | ((_isFw) ? 0 : 0xF0000000);}
  inline int getDist(bool fw) const {
    if (isFw() == fw) {
      return (contig_length - 1 - getPos());
    } else {
      return getPos();
    }
  }
};


struct ContigToTranscript {
  int trid;
  int pos; 
  bool sense; // true for sense, 
  ContigToTranscript() : trid(0), pos(0), sense(false) {}
  ContigToTranscript(int tridIn, int posIn, bool senseIn) : trid(tridIn), pos(posIn), sense(senseIn) {}
};

struct RefPos {
  uint32_t pos;
  bool isFW;
};
 
struct ProjectedHit {
  // The relative position of the k-mer inducing this hit on the
  // contig
  uint32_t contigPos_;
  // How the k-mer inducing this hit maps to the contig
  // true for fw, false for rc
  bool contigOrientation_; 
  uint32_t contigLen_;
  uint32_t k_;
  core::range<std::vector<ContigToTranscript>::iterator> refRange;
  inline bool empty() { return refRange.empty(); }

  inline RefPos decodeHit(ContigToTranscript& p) {
    // true if the contig is fowrard on the reference
    bool contigFW = p.sense;
    // we are forward with respect to the reference if :
    // (1) contigFW and contigOrientation_
    // (2) !contigFW and !contigOrientation_
    // we are reverse complement with respect to the reference if :
    // (3) configFW and !contigOrientation_
    // (4) !configFW and contigOrientation_

    // if we're in the forward orientation, then our position is
    // just the contig offset plus or relative position
    uint32_t rpos{0};
    bool rfw{false};
    if (contigFW and contigOrientation_) {
      // kmer   :          AGC
      // contig :      ACTTAGC
      // ref    :  GCA[ACTTAGC]CA
      rpos = p.pos + contigPos_;
      rfw = true;
    } else if (contigFW and !contigOrientation_) {
      // kmer   :          GCT
      // contig :      ACTTAGC
      // ref    :  GCA[ACTTAGC]CA
      rpos = p.pos + contigPos_;
      rfw = false;
    } else if (!contigFW and contigOrientation_) {
      // kmer   :          AGT
      // contig :      GCTAAGT
      // ref    :  GCA[ACTTAGC]CA
      rpos = p.pos + contigLen_ - (contigPos_ + k_);
      rfw = false;
    } else if (!contigFW and !contigOrientation_) {
      // kmer   :          ACT
      // contig :      GCTAAGT
      // ref    :  GCA[ACTTAGC]CA
      rpos = p.pos + contigLen_ - (contigPos_ + k_);
      rfw = true;
    }
    return {rpos, rfw};
  }
};

struct Contig {
  int id; // internal id
  int length; // number of k-mers
  int ec;
  std::string seq; // sequence
  std::vector<ContigToTranscript> transcripts;
  Contig() {}
  Contig(int idIn, int lengthIn, int ecIn, std::string&& seqIn, std::vector<ContigToTranscript>&& transcriptsIn) :
  id(idIn), length(lengthIn), ec(ecIn), seq(std::move(seqIn)), transcripts(std::move(transcriptsIn)) {}
  Contig(Contig&& o) : id(o.id), length(o.length), ec(o.ec), seq(std::move(o.seq)), transcripts(std::move(o.transcripts)) {}
  Contig(const Contig& o) : id(o.id), length(o.length), ec(o.ec), seq(o.seq), transcripts(o.transcripts) {}
  Contig& operator=(const Contig&) = default;
};

struct DBGraph {
  std::vector<int> ecs; // contig id -> ec-id
  std::vector<Contig> contigs; // contig id -> contig
//  std::vector<pair<int, bool>> edges; // contig id -> edges
};



struct KmerIndex {
  KmerIndex(const ProgramOptions& opt) : k(opt.k), num_trans(0), skip(opt.skip), target_seqs_loaded(false) {
    //LoadTranscripts(opt.transfasta);
  }

  ~KmerIndex() {}

  void match(const char *s, int l, std::vector<std::pair<KmerEntry, int>>& v) const;
//  bool matchEnd(const char *s, int l, std::vector<std::pair<int, int>>& v, int p) const;
  int mapPair(const char *s1, int l1, const char *s2, int l2, int ec) const;
  std::vector<int> intersect(int ec, const std::vector<int>& v) const;




  void BuildTranscripts(const ProgramOptions& opt);
  void BuildDeBruijnGraph(const ProgramOptions& opt, const std::vector<std::string>& seqs);
  void BuildEquivalenceClasses(const ProgramOptions& opt, const std::vector<std::string>& seqs);
  void FixSplitContigs(const ProgramOptions& opt, std::vector<std::vector<TRInfo>>& trinfos);
  bool fwStep(Kmer km, Kmer& end) const;

  // output methods
  void write(const std::string& index_out, bool writeKmerTable = true);
  void writePseudoBamHeader(std::ostream &o) const;
  
  // note opt is not const
  // load methods
  void load(ProgramOptions& opt, bool loadKmerTable = true);
  void loadTranscriptSequences() const;

  auto getRefPos(Kmer& mer) -> ProjectedHit;


  // positional information
  std::pair<int,bool> findPosition(int tr, Kmer km, KmerEntry val, int p = 0) const;

  int k; // k-mer size used
  int num_trans; // number of targets
  int skip;

  KmerHashTable<KmerEntry, KmerHash> kmap;
  EcMap ecmap;
  DBGraph dbGraph;
  std::unordered_map<std::vector<int>, int, SortedVectorHasher> ecmapinv;
  const size_t INDEX_VERSION = 10; // increase this every time you change the fileformat

  std::vector<int> target_lens_;

  std::vector<std::string> target_names_;
  std::vector<std::string> target_seqs_; // populated on demand
  bool target_seqs_loaded;


};








#endif // KALLISTO_KMERINDEX_H
