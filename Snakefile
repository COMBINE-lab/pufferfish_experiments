bwa = config["bwa"]
debga = config["debga"]
kallisto = config["kallisto"]
puffer = config["pufferfish"]
data_path  = config["data_path"]
output_path  = config["output_path"]

human_txome_ref = config["human_txome_ref"]
human_genome_ref = config["human_genome_ref"]
datasets = [human_txome_ref, human_genome_ref]

human_txome_read = config["human_txome_read"]
human_genome_read = config["human_genome_read"]



rule all:
     input:
      expand("{out}/{outfiles}.bwa_idx", out=output_path, outfiles=datasets),
      expand("{out}/{outfiles}.kallisto_idx", out=output_path, outfiles=datasets),
      expand("{out}/{outfiles}.puffer_idx", out=output_path, outfiles=datasets),
      expand("{out}/benchmarks/{ref}_vs_{read}.kallisto.lookup.benchmark.txt", out=output_path, ref=human_txome_ref, read=human_txome_read),
      expand("{out}/benchmarks/{ref}_vs_{read}.kallisto.lookup.benchmark.txt", out=output_path, ref=human_genome_ref, read=human_genome_read),
      expand("{out}/benchmarks/{ref}_vs_{read}.puffer.lookup.benchmark.txt", out=output_path, ref=human_txome_ref, read=human_txome_read),
      expand("{out}/benchmarks/{ref}_vs_{read}.puffer.lookup.benchmark.txt", out=output_path, ref=human_genome_ref, read=human_genome_read),

rule bwa_lookup:
     input :
           index = os.path.sep.join([data_path, "{ref}.fa"]),
           reads = os.path.sep.join([data_path, "{reads}.fa"])
     output :
           os.path.sep.join([output_path, "benchmarks/{ref}_vs_{reads}.bwa_idx"])
     benchmark:
          os.path.sep.join([output_path, "benchmarks/{ref}_vs_{reads}.debga.index.benchmark.txt"])
     message:
          bwa + " fastmap {input.index} {input.reads}"
     shell :
           bwa + " fastmap {input.index} {input.reads}"


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

rule bwa_index:
     input :
           os.path.sep.join([data_path, "{ref}.fa"])
     output :
           os.path.sep.join([output_path, "{ref}.bwa_idx"])
     benchmark:
          os.path.sep.join([output_path, "benchmarks/{ref}.bwa.index.benchmark.txt"])
     message:
          bwa + " index {input} -p {output}/bwa"
     shell :
           bwa + " index {input} -p {output}/bwa"


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



