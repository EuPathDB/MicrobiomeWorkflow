# 16s workflow

![pic](https://static.wikia.nocookie.net/looneytunes/images/1/1d/Granny_New_Looney_Tunes.png/revision/latest?cb=20170716232318)

## Overview

1. [Obtain the sample details sheet and a list of .fastqs](#sample-details-and-fastqs)
2. [Prepare manual delivery folder](#prepare-manual-delivery-folder)
3. [Provide fastqs and adjust IDs in sample details sheet](#provide-fastqs-and-adjust-ids)
4. [Add new dataset entry](#add-new-dataset-entry)
5. Undo live site workflow for adding a new study [ReFlow guide doc](./live-site-reflow.md)
6. [Run analysis and check results](#run-analysis-and-check-results)
7. Update the live site [Live site main guide doc](./live-site-guide.md) and maybe even the EDA site [EDA main guide doc](./eda-guide.md)


## Sample details and fastqs
Start this when you have a sample details sheet and a list of inputs given to you, and get the ontology team to map the sample details header to the microbiome.owl (for live site) and microbiome-human-only.owl (for human EDA studies).

## Prepare manualDelivery folder

To create:

```
studyName=Ciara_V1V3
studyVersion=20190322

mkdir -pv /eupath/data/EuPathDB/manualDelivery/MicrobiomeDB/common/MicrobiomeStudy/$studyName/$studyVersion/{fromProvider,workspace,final}

```

Fastqs or a list of fastqs go in a folder named `final`. If providing study ID leave the directory empty.

Work scripts etc. go in the folder named `workspace`. Put the commands you use in a script, or at least keep history with something like `history | tail > history.txt`. 

Anything from Dan goes in `fromProvider`.

## Provide FASTQs and adjust IDs
Figure out what your fastqs are and how you are going to provide them. The newest, most optimal and advisable option is to provide a list - the `sraSampleAndRunIdsFileName` parameter in the dataset - but before this was developed you could also provide `sraStudyId` or a folder of fastqs.
 
To make a list, create a file in a final directory, name it whatever you will put in `sraSampleAndRunIdsFileName`, and format it with three columns:
```
SRS4060960      SRR8216065      PAIRED
SRS4060959      SRR8216066      PAIRED
SRS4060958      SRR8216067      PAIRED
SRS4060957      SRR8216068      PAIRED
SRS4060956      SRR8216069      PAIRED
```
This will produce results keyed by IDs like `SRS000123.SRR000456`, so prepare your sample detail sheet accordingly.

Exceptions:
- when providing a `sraStudyId` you will get the same result names too
- when merging technical replicates - done in a few old studies - the fastqs start like that, but end up as `SRS000123` - so that's how they need to be in the sample details sheet
- when not downloading from SRA and not merging tech reps you will choose some IDs, the code will do something with them, and then you'll have to correct the sample details sheet


You might need to make other adjustments to the sample details file - see 
[sample details guide](sample-details-guide.md)
## Add new dataset entry


### New dataset stanza

You need to prepare one of these entries in `Datasets/lib/xml/datasets/MicrobiomeDB.xml`:

```
  <dataset class="MicrobiomeStudy">
    <prop name="projectName">$$projectName$$</prop>
    <prop name="name">Ciara_V1V3</prop>
    <prop name="version">20190322</prop>
...
  </dataset>
```
and choose parameters for the study. Have a look at how other 16s studies are configured, and open [the DADA2 tutorial](https://benjjneb.github.io/dada2/tutorial.html) so you have it for reference.


### Download a few fastqs
Amplicon sequencing is quite variable, and you will have to look at the fastqs, so download a few.

Use the NCBI tool `prefetch`, it can even can somehow deal with weird data availability issues for studies in dbGAP (encountered for the StLouisNICU study).

```
cd /eupath/data/EuPathDB/manualDelivery/MicrobiomeDB/common/MicrobiomeStudy/$studyName/$studyVersion/workspace/

srr=SRR12184420
echo $srr \
   | while read -r srr ; do prefetch -O ../fromProvider $srr ; done


for f in ../fromProvider/*sra ; do fastq-dump --split-files $f ; done

```

Providing `--split-files` is important, because `fastq-dump` will by default prepare a file with merged reads, which is not good.

### Figure out the parameter values

#### isPaired
It says on the SRX accessions [https://www.ebi.ac.uk/ena/browser/api/xml/SRX8714110](https://www.ebi.ac.uk/ena/browser/api/xml/SRX8714110) (LIBRARY_LAYOUT is single or not) and also you will get either single or paired fastqs.

#### Platform
Illumina is default, 454 is pyrosequencing. Written in the SRX xml. Most likely Illumina, because 454 technology is old.

#### Trimming and truncating parameters

I rely on a script fastq2qualitystats.pl. Its output looks like that:
```
POSITION        FRAC_READS      AVG_Q
1       1.000   1.9
2       1.000   1.8
3       1.000   1.7
4       1.000   1.7
5       1.000   1.6
6       1.000   3.7
7       1.000   3.6
8       1.000   2.6
9       1.000   3.9
10      1.000   4.9
...
150	0.900	4.4
...
200	0.123	0.4
...
```
The `POSITION` column is a counting number, from 1 to the length of the longest read.

The `FRAC_READS` column is, how many reads had at least this many bases. In the above example, of the reads 90% are over 150 bases long, but most reads are shorter than 200 bases.

The `AVG_Q` column is an average quality for each read in this position. Typically the first few bases are of lower quality, and the quality decays again at the end of each read.
Sometimes people submit truncated reads - then there is no decaying tail.

Look through a few at a time with e.g.
```
paste \
  <( fastq2qualitystats.pl SRR12919073_1.fastq   ) \
  <( fastq2qualitystats.pl SRR12919090_1.fastq  ) \
  <( fastq2qualitystats.pl SRR12919091_1.fastq  )  \
  | tee qualitystats.txt
```

#### trimLeft
This is to remove the first few bases of lower quality. See how the scores look and where they pick up.

#### truncLen
Unless the reads were already truncated, the reads will eventually drop in quality. Pick the longest length where most reads are still good quality.

#### readLen / Max read length
454 only. This option rejects reads that are too long (because they are suspect in 454 technology). Not clipping, rejecting whole reads. See where `FRAC_READS` tails off, and aim to remove maybe max 5% of the reads with this option.

#### trimLeftR, truncLenR
leave empty for single layout. For paired layout, determine the values in the same way on `*_2.fastq`s downloaded.

#### mergeTechReps
Set to `false` unless there are multiple runs per sample ( multiple SRRs per SRS ). If there are, if you set it to `true`, the abundances will get added up between runs per sample, at the ASV level.

## Run analysis and check results
This analysis is a DJob. The overview of the code run is in the [What is where](./what-is-where.md)


There's a step of provisioning and filtering fastqs, followed by fanning out by sample, followed by a joint "ASV to taxon" task at the end.


After the fastqs get filtered check how many reads you still have - you should have about 80% of the input reads in each fastq - if there is much less, maybe the filtering parameters are wrong?

When doing the "D" part of the DJob, each sample is a task, and the results for each task are a list of ASVs that represent contents of the sample. If a few tasks fail - no organisms detected in those samples - that is probably okay. If lots of them fail, the filtering and trimming parameters might be wrong.

The joint "ASV to taxon" task at the end should produce some sensible species assignments - check the result file to see that the organisms you would expect to be there are indeed there, etc. Also check the ASVs file, make sure that they're not weird: should be at least 60bp long, etc.

If it's not obviously weird, load the study, and show it to the data providers!
