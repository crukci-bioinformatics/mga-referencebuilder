Reference Genome Selection
==========================

The bacterial sequences making up this reference set are a subset of
approximately 900 genomes selected from NCBI's collection of bacterial
and archaeal genomes.

The objective was to find a subset that covers the variety of bacteria and
archaea, without having to index all of the "reference" and "representative"
genomes, because there are now too many to index usefully.  This journal
article:

Mukherjee, Seshadri, Varghese et al.  "1,003 reference genomes of bacterial and
archaeal isolates expand coverage of the tree of life".  Nature Biotechnology
35, 676-683 (2017 June 12).

https://www.nature.com/articles/nbt.3886

describes a set of about 1000 genome assemblies that span the bacteria and
archaea (part of the "Genomic Encyclopedia of Bacteria and Archaea", or GEBA
initiative).  Rather than use these assemblies themselves, we chose reference
or representative assemblies (or sometimes "na" if no representative was
available) from GenBank that were from the same species, though possibly not
the same strain or isolate, on the grounds that having been curated, they are
probably higher quality than the assemblies described in the manuscript.  (In
addition, it proved difficult to match some of the accession numbers from the
manuscript with the corresponding genome sequences.)

Methods
=======

The match_genomes.py script reads the assembly summary file and the list of
genomes described in the article.  It then, for each species in the article,
finds the set of genomes in the assembly summary that match its species.  From
that list, a genome is selected to be included in our reference set.  If there
is a reference genome in the list, it is chosen.  Otherwise a representative
genome is chosen, if there is one.  (If there is more than one, one is chosen
arbitrarily.)  Otherwise another genome is chosen, again arbitrarily if there
is more than one.  The list is written out as tab-separated text.  (Files are
listed below.)

E. coli and Mycoplasma were manually from the list, then the get_genomes.py
script was used to retrieve the genome sequences from GenBank.  The genomes
were uncompressed, and concatenated into "bacterial_reference_genomes.fa"
(found in the fasta directory), and a bowtie index was made from that file.  

Files
=====

In this directory:

nbt.3886.xlsx -- supplemental data from the manuscript, listing the 1003
genomes with various metadata

In the "bin" directory:

match_genomes.py -- a script to select, from the assembly summary, genomes
corresponding with the species listed in supplemenetal data.  The output is
bacterial_reference_genomes.txt.

get_genomes.py -- a script to retrieve the sequences from GenBank, given the
reference genomes list above.

fetch.sh -- a script to fetch assembly_summary.txt from NCBI, filter it
with match_genomes.py, fetch each selected genome with get_genomes.py and
create one FASTQ file from all those references.

