nextflow.enable.dsl = 2
params.out = "${launchDir}/output"
params.storedir = "${baseDir}/cache"
params.accession= null 
params.url="https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=M21012&rettype=fasta&retmode=text"
params.infile = "/home/cq/visual studio/cq-examples-master/data/hepatitis/*.fasta"
params.collectFile="collect.fasta"
params.mafft="mafft.fasta"


// that downloaded from github , in infile path you can change the path according to your folder location 
// by writing --infile in command line 
// also if you want to change the URl you can make it in the command --url
// -- accession to change your accession 

process downloadRefFile {
 publishDir "${params.out}", mode: "copy", overwrite: true
  input:
       val accession  
  output:
       path "referance.fasta"

 
  """
  wget  -O ${params.url}referance.fasta

  """
}



process collectFastaFile{
   publishDir "${params.out}", mode: "copy", overwrite: true
  input:
       path infile 
       path referancefile
  output:
       path "collect.fasta"  

 """
 cat *.fasta  >  collect.fasta
 """  
}

process mafft{
  container "https://depot.galaxyproject.org/singularity/mafft%3A7.464--h516909a_0"
  input:
      path collectFile
  output:
      path "mafft.fasta"
 """
 mafft ${collectFile}  > mafft.fasta
 """   

}

process trimal{
  container "https://depot.galaxyproject.org/singularity/trimal%3A1.4.1--h2d50403_2"
  input:
      path mafft
  output:
      path "trimal.fasta"
      path "trimal.html"
 """
 trimal -in ${mafft}  -out trimal.fasta -automated1 -htmlout trimal.html
 """   

}



workflow {
if(params.infile == null && params.url == null) {
        print "ERROR: Please provide one of --infile or --url."
        System.exit(1)
}
    referancefasta=downloadRefFile(channel.from(params.accession))
    collectfile=collectFastaFile(referancefasta,channel.fromPath(params.infile).collect())
    mafftresult=mafft(collectfile)
    trimal(mafftresult)
}

// LEK :Wedad Ahmed