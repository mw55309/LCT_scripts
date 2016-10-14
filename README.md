# Scripts for lowest-common-taxon analysis

The basic method is:
* map reads to GREENGENES database
* make sure aligner is set to report ALL best hits
* where a read hits multiple 16S sequences equally well, take the lowest-common-taxon

Input:

Preprocess the GREENGENES database to have a tab-delimited file like this:

```sh
228054  k__Bacteria; p__Cyanobacteria; c__Synechococcophycideae; o__Synechococcales; f__Synechococcaceae; g__Synechococcus; s__
844608  k__Bacteria; p__Cyanobacteria; c__Synechococcophycideae; o__Synechococcales; f__Synechococcaceae; g__Synechococcus; s__
178780  k__Bacteria; p__Cyanobacteria; c__Synechococcophycideae; o__Synechococcales; f__Synechococcaceae; g__Synechococcus; s__
198479  k__Bacteria; p__Cyanobacteria; c__Synechococcophycideae; o__Synechococcales; f__Synechococcaceae; g__Synechococcus; s__
187280  k__Bacteria; p__Cyanobacteria; c__Synechococcophycideae; o__Synechococcales; f__Synechococcaceae; g__Synechococcus; s__
179180  k__Bacteria; p__Cyanobacteria; c__Synechococcophycideae; o__Synechococcales; f__Synechococcaceae; g__Synechococcus; s__
175058  k__Bacteria; p__Cyanobacteria; c__Synechococcophycideae; o__Synechococcales; f__Synechococcaceae; g__Synechococcus; s__
176884  k__Bacteria; p__Cyanobacteria; c__Synechococcophycideae; o__Synechococcales; f__Synechococcaceae; g__Synechococcus; s__
228057  k__Bacteria; p__Proteobacteria; c__Alphaproteobacteria; o__Rickettsiales; f__Pelagibacteraceae; g__; s__
234102  k__Bacteria; p__Proteobacteria; c__Alphaproteobacteria; o__Rickettsiales; f__Pelagibacteraceae; g__; s__
```

First column is sequence ID and second column is the taxonomy.  The script assumes this file GZIP-ed and uses zcat in the decompression.

Obviously build an index from the GREENGENES fasta file.

The aligner will no doubt output SAM/BAM, so that needs to be processed to output a UNIQUE list of read_id to hit pairs, e.g.

```sh
HWI-D00200:106:H790UADXX:2:1101:10046:69878     100067
HWI-D00200:106:H790UADXX:2:1101:10046:69878     1001141
HWI-D00200:106:H790UADXX:2:1101:10046:69878     1002076
HWI-D00200:106:H790UADXX:2:1101:10046:69878     1003399
HWI-D00200:106:H790UADXX:2:1101:10046:69878     100392
HWI-D00200:106:H790UADXX:2:1101:10046:69878     1005554
HWI-D00200:106:H790UADXX:2:1101:10046:69878     1008137
HWI-D00200:106:H790UADXX:2:1101:10046:69878     1008138
HWI-D00200:106:H790UADXX:2:1101:10046:69878     1008773
HWI-D00200:106:H790UADXX:2:1101:10046:69878     100979
```

The first column here is the read ID, the second column is the GREENGENES sequence ID.  As I said, this should be a unique list (i.e. don't report two rows when both reads in a pair hit the same ID).

I usually do this with something like:

```sh
samtools view in.bam | awk '$3 != "*"' | awk '{print $1"\t"$3}' | sort -T /path/to/large/temp/dir | uniq | gzip > output.txt.gz
```

Once we have that, it's simple to run the script:

```sh
perl txt2taxon.pl outputprefix <list of output.txt.gz separated by spaces>
```

NOTE: when providing multipl output.txt.gz files, these should come from the SAME SAMPLE

This will produce two files:
* outputprefix.taxon.all.txt
* outputprefix.taxon.lowest.txt

The former provides verbose output as to all taxon assignments for each input read, and the latter provides the lowest-common-taxon for each read.

The script levelreport.pl can then be used with the \*taxon.lowest.txt files to get a taxon report for either (k)ingdom, (p)hylum, (c)lass, (o)rder, (f)amily, (g)enus or (s)pecies:

```sh
# kingdom
perl levelreport.pl k outputprefix.taxon.lowest.txt

# genus
perl levelreport.pl g outputprefix.taxon.lowest.txt
```

## Example

```sh
# generate reports
perl txt2taxon.pl test example/test.txt.gz

# get kingdom level summary
perl levelreport k example/test.taxon.lowest.txt

# get genus level summary
perl levelreport.pl g example/test.taxon.lowest.txt
```

