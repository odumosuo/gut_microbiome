#!/bin/sh

####Load blast####
#Make directory for assignment
mkdir Alignment

#load blast module
module load blast+/2.12.0

#Get information and figure out the extensions I need for blast module
module spider blast+/2.12.0

#load needed module for BLAST module
module load StdEnv/2020 gcc/9.3.0

#load blast module
module load blast+/2.12.0


####organize####
#create directory for the raw files and the files to submit in Alignment directory
mkdir Raw_files Submit_files

#send DL_1.txt, PM_1.txt, and new_ reference file from local computer to compute Canada in Raw_files directory while in correct directory on local computer.
scp ./DL_1.txt ./PM_1.txt ./new_reference.ft odumosuo@graham.computecanada.ca:scratch/Alignment/Raw_files

#create files that will have DL and PM sequences name, sequence genus assignment and highest BLAST bit score (touch DL_match.txt PM_match.txt) and files for unique genera for DL and PM and file for the shared genera between them (DL_unique.txt PM_unique.txt DL_PM_common.txt) while in correct directory.
touch DL_match.txt PM_match.txt DL_unique.txt PM_unique.txt DL_PM_common.txt

#make a directory for BLAST databases in Alignment directory
mkdir Blast_databases

####BLAST####
#Create BLAST databases from new-reference.ft. Required to run BLAST and support automatic resolution of sequence identifiers. While in correct directory and naming the files reference_blast_database
makeblastdb -in ../Raw_files/new_reference.ft -dbtype nucl -out reference_blast_database

#make a directory called blast results in Alignment directory
mkdir ../Blast_results


####Get needed information from blast####
#create blast results that only contain only the first (highest) match (-max_target_seqs 1) and are tab delineated (-outfmt 6), (qseqid) to return the query seq_id and (stitle) for the subject title. Name highest_dl_match and highest_pm_match. Pipe to remove duplicate genus. Genus with “_” followed by a number are duplicates. Overright DL_match.txt PM_match.txt

blastn -db reference_blast_database -query ../Raw_files/DL_1.txt -max_target_seqs 1 -outfmt '6 qseqid stitle bitscore' | sed -E 's/_[0-9]+//2' > ../Submit_files/DL_match.txt

blastn -db reference_blast_database -query ../Raw_files/PM_1.txt -max_target_seqs 1 -outfmt '6 qseqid stitle bitscore' | sed -E 's/_[0-9]+//2' > ../Submit_files/PM_match.txt





####Find matching genus####
# Cut the second column in DL_match.txt and PM_match.txt. name file genus_only_dl_blastresults and genus_only_pm_blastresults. Print only unique occurrences (sort -u).
cut -f2 ../Submit_files/DL_match.txt | sort -u > genus_only_dl_blastresults
cut -f2 ../Submit_files/PM_match.txt | sort -u > genus_only_pm_blastresults

#Find matching genus and print to override files DL_PM_common.txt. Grep for matching genus/strings. (-f) to obtain patterns from file, (-x) for exact match of whole line, and  (-F) for search pattern as fixed-strings. Print only unique occurrences (sort -u).
grep -xF -f genus_only_dl_blastresults genus_only_pm_blastresults | sort -u > ../Submit_files/DL_PM_common.txt


####Find non-matching genus####
#Find non-matching genus names between DL and PM. Name file nonmatching_genus.  (-v) for select non-matching lines. Print only unique occurrences (sort -u). It will print non-matches from the second document. The second document is being compared to the first. Override file DL_unique.txt and PM_unique.txt. Print only unique occurrences

grep -xvF -f genus_only_dl_blastresults genus_only_pm_blastresults  | sort -u > ../Submit_files/PM_unique.txt

grep -xvF -f genus_only_pm_blastresults  genus_only_dl_blastresults  | sort -u > ../Submit_files/DL_unique.txt
