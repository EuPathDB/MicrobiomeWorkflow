# WGS guide

![pic](https://static.wikia.nocookie.net/looneytunes/images/8/8c/Strifebeaky.jpg/revision/latest/scale-to-width-down/376?cb=20200409055102)

This is a guide to setting up a new analysis in the manual delivery folder and an entry in the [MicrobiomeDatasets file](https://github.com/VEuPathDB/MicrobiomeDatasets/blob/master/Datasets/lib/xml/datasets/MicrobiomeDB.xml).

Running those analyses is currently done by the live site workflow - see [Main guide](live-site-guide.md) for overview, and [PMACS operations] for pmacs commands.

Overall:

1. [Obtain the sample details sheet and a list of .fastqs](#sample-details-and-fastqs)
2. [Prepare manual delivery dir](#prepare-manual-delivery-dir)
2. [Add a new MicrobiomeStudy dataset to MicrobiomeDB.xml](#add-new-dataset-entry)
3. [Choose parameters](#choose-parameters) 
4. [Make sure ids match between fastqs and sample details](#make-ids-match)
5. Undo live site workflow for adding a new study [ReFlow guide doc](./live-site-reflow.md)
6. [Run analysis and check results](#run-analysis-and-check-results)
7. Update the live site [Live site main guide doc](./live-site-guide.md) and maybe even the EDA site [EDA main guide doc](./eda-guide.md)

## Sample details and fastqs
Start this when you have a sample details sheet and a list of inputs given to you, and get the ontology team to map the sample details header to the microbiome.owl (for live site) and microbiome-human-only.owl (for human EDA studies).

## Prepare manual delivery dir

Make a new folder:
```
STUDY=MORDOR_metatranscriptome
VERSION=20220509
MD=/eupath/data/EuPathDB/manualDelivery/MicrobiomeDB/common

mkdir -p $MD/MicrobiomeStudy/$STUDY/$VERSION/{final,fromProvider,workspace}
```

The list of fastqs goes in a folder named `final`.

Work scripts etc. go in the folder named `workspace`. Put the commands you use in a script, or at least keep history with something like `history | tail > history.txt`. 

Anything from Dan goes in `fromProvider`.


## Provide FASTQs and adjust IDs
Pick a file name, then make a list of fastqs in the manual delivery dir `final` under that file name.

For the correct format of the list, see an existing study.

The first column in the list of fastqs should be the sample name in the sample details file.

If the sample details file has the submitter IDs and not archive IDs, adjust the sample details file. The submitter could tell you how their IDs match archive accessions, or you can usually figure it out from ENA.
For example, this is what Wojtek did for the MORDOR study - example from `/eupath/data/EuPathDB/manualDelivery/MicrobiomeDB/common/MicrobiomeStudy/MORDOR_metatranscriptome/20220329/workspace/`:

```
# Get a list of SRRs for the MORDOR study (PRJNA549968)
curl --silent 'https://www.ebi.ac.uk/ena/portal/api/filereport?accession=PRJNA549968&result=read_run&fields=sample_accession,secondary_sample_accession,run_accession,fastq_ftp,fastq_md5,fastq_bytes' > ena.tsv

# Go through XML pages for each SRS, get the submitter ID which matches IDs in provided file
cat ena.tsv  | tail -n+2 | cut -f2,3 | while read srs srr; do echo $srs $srr $( curl "https://www.ebi.ac.uk/ena/browser/api/xml/$srs" | grep SUBMITTER_ID ) ; done > curls.out

# reformat into a list
cat curls.out | perl -nE 'm{(SRS\d+) (SRR\d+) <SUBMITTER_ID label="Sample name" namespace="pda\|armin_h">(.*)</SUBMITTER_ID>} or die $_; say "$1\t$2\t$3"' | tee ids.tsv

```
Then Wojtek adjusted the sample details file so that it uses archive IDs instead of the provided IDs.

## Add new dataset entry
Open the [MicrobiomeDatasets file](https://github.com/VEuPathDB/MicrobiomeDatasets/blob/master/Datasets/lib/xml/datasets/MicrobiomeDB.xml) and find an existing WGS study. For example:
```
  <dataset class="MicrobiomeStudy">
    <prop name="projectName">$$projectName$$</prop>
    <prop name="name">MORDOR_metatranscriptome</prop>
    <prop name="version">20220329</prop>
...
  </dataset> 
```
Copy it with your name and version. Most parameters will be blank - they are for 16s.

## Choose parameters
### Provisioning method for fastqs
This is the `downloadMethod` parameter. Best one is `sra` if your data is in SRA.

### List of fastqs
This is the `sampleToWgsFastqFileName` parameter. 



## Run analysis and check results
There are two pipelines to run - `humann` and `CORRAL`. See [PMACS operations doc](pmacs-operations.md) for details on how to run them.

Open the files and make sure there's something in them! CORRAL might produce very little, and that's okay, but if `humann` doesn't produce any results then the data is bad. There's no way to fix a `humann` run if it doesn't identify any bacteria or gene markers, and no knobs to turn and twiddle etc. and we had to reject studies before - for example, the California mosquitos study turned out to not have enough identifiable bacterial DNA.

