debga = config["debga"]
kallisto = config["kallisto"]
puffer = config["pufferfish"]
data_path  = config["data_path"]
output_path  = config["output_path"]
human_txome = config["human_txome"]

rule all:
     input:
      expand("{out}/gencode.v25.pc_transcripts_fixed.debga_idx", out=output_path),
      expand("{out}/gencode.v25.pc_transcripts_fixed.kallisto_idx", out=output_path),
      expand("{out}/gencode.v25.pc_transcripts_fixed.puffer_idx", out=output_path),
      expand("{out}/benchmarks/gencode.v25.pc_transcripts_fixed_vs_human_txome_reads.kallisto.lookup.benchmark.txt", out=output_path),
      expand("{out}/benchmarks/gencode.v25.pc_transcripts_fixed_vs_human_txome_reads.puffer.lookup.benchmark.txt", out=output_path)

rule debga_index:
     input :
           os.path.sep.join([data_path, "{ref}.fa"])
     output :
           os.path.sep.join([output_path, "{ref}.debga_idx"])
     benchmark:
          os.path.sep.join([output_path, "benchmarks/{ref}.debga.index.benchmark.txt"])
     message:
          debga + " index -k 27 {input} {output}"
     shell :
           debga + " index -k 27 {input} {output}"


rule kallisto_lookup:
     input :
           index = os.path.sep.join([output_path, "{ref}.kallisto_idx"]),
           reads = os.path.sep.join([data_path, "{reads}.fa"])
     output:
          os.path.sep.join([output_path, "benchmarks/{ref}_vs_{reads}.kallisto.lookup.benchmark.txt"])
     benchmark:
          os.path.sep.join([output_path, "benchmarks/{ref}_vs_{reads}.kallisto.lookup.benchmark.txt"])
     message:
          kallisto + " lookup -i {input.index} {input.reads}"
     shell :
          kallisto + " lookup -i {input.index} {input.reads}"


rule puffer_lookup:
     input :
           index = os.path.sep.join([output_path, "{ref}.puffer_idx"]),
           reads = os.path.sep.join([data_path, "{reads}.fa"])
     output:
          os.path.sep.join([output_path, "benchmarks/{ref}_vs_{reads}.puffer.lookup.benchmark.txt"])
     benchmark:
          os.path.sep.join([output_path, "benchmarks/{ref}_vs_{reads}.puffer.lookup.benchmark.txt"])
     message:
          puffer + " lookup -i {input.index} -r {input.reads}"
     shell :
          puffer + " lookup -i {input.index} -r {input.reads}"


rule kallisto_index:
     input :
           os.path.sep.join([data_path, "{ref}.fa"])
     output :
           os.path.sep.join([output_path, "{ref}.kallisto_idx"])
     benchmark:
          os.path.sep.join([output_path, "benchmarks/{ref}.kallisto.index.benchmark.txt"])
     message:
          kallisto + " index -k 27 -i {output} {input}"
     shell :
           kallisto + " index -k 27 -i {output} {input}"

rule puffer_index:
     input :
           os.path.sep.join([data_path, "{ref}.k27.pufferized.gfa"])
     output :
           os.path.sep.join([output_path, "{ref}.puffer_idx"])
     benchmark:
          os.path.sep.join([output_path, "benchmarks/{ref}.puffer.index.benchmark.txt"])
     message:
          puffer + " index -k 27 -o {output} -g {input}"
     shell :
           puffer + " index -k 27 -o {output} -g {input}"
