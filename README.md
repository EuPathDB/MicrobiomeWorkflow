# MicrobiomeWorkflow - current site

## Where is the code?
Dan asked once, and Wojtek produced this handy overview!

1. The workflow graph is in https://github.com/VEuPathDB/MicrobiomeWorkflow/tree/master/Main/lib/xml and also https://github.com/VEuPathDB/EbrcModelCommon/blob/master/Model/lib/xml/datasetClass/classes.xml.
2. The individual steps are in https://github.com/VEuPathDB/MicrobiomeWorkflow/tree/master/Main/lib/perl, they inherit from common steps in https://github.com/VEuPathDB/ApiCommonWorkflow/ and https://github.com/VEuPathDB/ReFlow/.
3. The Perl code for loading the results is mostly in https://github.com/VEuPathDB/ApiCommonData - our bits start with "MBio" in https://github.com/VEuPathDB/ApiCommonData/tree/master/Load/lib/perl and the unit tests are in https://github.com/VEuPathDB/ApiCommonData/tree/master/Load/t.
4. The ontology parts - common, but received a lot of work to accomodate MicrobiomeDB and later EDA - start with CBIL::ISA::InvestigationSimple, and other stuff in https://github.com/VEuPathDB/CBIL/tree/master/ISA.
5. The 16s workflow is the task of running DADA2 in DJob - https://github.com/VEuPathDB/DJob/tree/master/DistribJobTasks/bin/dada2 for individual scripts, and there's also https://github.com/VEuPathDB/DJob/blob/master/DistribJobTasks/lib/perl/ASVTableTask.pm that calls out to them.
6. There's no one WGS workflow, there are two separate tasks: `humann` - https://github.com/VEuPathDB/humann-nextflow - and `CORRAL` on https://github.com/wbazant/CORRAL/
7. The `humann` workflow relies on custom forks of `humann` (https://github.com/wbazant/humann) and `kneaddata` (https://github.com/wbazant/kneaddata). Not much is done with the results, except decorating with taxon IDs and loading appropriately.

## Where is the data?
Manual delivery dir: `/eupath/data/EuPathDB/manualDelivery/MicrobiomeDB/common/MicrobiomeStudy`
This has many .fastqs for 16s analyses. For WGS we don't serve .fastq files from manual delivery directories.

`/eupath/data/EuPathDB/workflows/MicrobiomeDB/5/` is the current workflow directory.

List of studies is at: https://github.com/VEuPathDB/MicrobiomeDatasets/.

Sample details for are at: https://github.com/VEuPathDB/ApiCommonMetadataRepository/tree/master/ISA/metadata/MBSTDY0020.

PMACS workflow dir is at: /project/eupathdblab/workflows/MicrobiomeDB/5/data

## What is the workflow graph like?
The root is in https://github.com/VEuPathDB/MicrobiomeWorkflow/blob/master/Main/lib/xml/workflowTemplates/microbiomeRoot.xml. Convenience features include:
- beginMicrobiomeStudies undoes everything related to running computations
- all computations write their final results to one directory, `all_results`
- all computations have a "skip if file" based on `all_results` dir contents

So, you can play fast and loose with that part, as long as `all_results` contents are good you can recover the workflow state without re-computation.

Loading sample details is a pain. The current deal is that Dan prepares sample details and Jie does the ontology terms, so there's a collaboration element to it - Wojtek normally ran workflows first, told Dan they've succeeded, and only got the sample details after that. Loading doesn't always run super smoothly - you need to get a lot of things right, and then load everything - which takes about three hours - and see if it shows up. See "Troubleshooting" for details.

There's a manual step of adding CORRAL results to sample details files - see "Operations".

## Troubleshooting

### Studies not showing up correctly? checklist
- IDs need to match between result files and sample details files
- sample details file needs to contain "env_feature" (for cross study query)
- EukDetect files need to have been added to sample details (and for that the sample details files need to be sorted on the first column)
- sample details and ontologies need to match
- study name needs to match in `$PROJECT_HOME/MicrobiomePresenters/Model/lib/xml/datasetPresenters/MicrobiomeDB.xml`, `$PROJECT_HOME/ApiCommonMetadataRepository/ISA/metadata/MBSTDY0020/i_Investigation.xml`, `$PROJECT_HOME/MicrobiomeDatasets/Datasets/lib/xml/datasets/MicrobiomeDB.xml`
- the build number in the presenter needs to be <= the one in the model
- the build number in the model needs to be up to date
- there needs to be an entry for that build number in the build dates file
- tuning manager needs to have run
- site needs to have been rebuilt

## Operations

### Prepare sample details
You need to have a TSV file, match ontology mappings for it (`ontologyMappingsMicrobiome.xml`), and make sure the ontology file is good (`microbiome.owl`). Dan will give you sample details, and Jie will give you the updated .owl. Then check the contents and load them.

#### Produce summary of a sample details file
```
cd $PROJECT_HOME/ApiCommonMetadataRepository

./scripts/summarise_ISA.pl ./ISA/metadata/MBSTDY0020/DIABIMMUNE_WGS.txt ./ISA/config/ontologyMappingsMicrobiome.xml 
```
These summaries are very useful for making changes, because you can diff the outputs before and after the change.

#### Run assertions on the file
```
cd $PROJECT_HOME/ApiCommonMetadataRepository

PERL5LIB=$GUS_HOME/lib/perl:PERL5LIB SPARQLPATH=scripts/lib/ApiCommonData/Load/lib/SPARQL/ perl ./scripts/microbiomedb.t
```
The test is useful for enforcing our SOPs about what sample details should be present - if `env_feature` isn't present the cross study query won't work correctly, everything else is for consistency.

We don't follow the SOPs completely, but they're helpful to an extent. The test also fails if the mapping isn't complete.

### Add CORRAL results to sample details

You need to start with a vaguely good TSV + ontology mappings + .owl, and then modify them, so that they include the CORRAL results. The versions without this step applied are in the source control, and get the results added on top.

This program takes care of the sample details:
```
$PROJECT_HOME/MicrobiomeWorkflow/Main/scripts/add_eukdetect_terms_to_sample_details.sh
```

This program produces stanzas that you'll need to paste into microbiome.owl and ontologyMappingsMicrobiome.xml:
```
/home/wbazant/project_home/MicrobiomeWorkflow/Main/scripts/extend_owl.pl
```

### Set up 16s computations
There are number of "season to taste" parameters for this, that depend on how amplicon data was produced.

Follow the DADA2 tutorial to learn how to set the values. Wojtek usually downloaded a few .fastq files, and ran a script fastq2qualitystats.pl on them to see where quality stats pick up and drop off, and chose appropriate trimming parameters.
 
## ReFlow commands
These are handy steps of undo + build + do to follow if you want to accomplish a particular task.

### Do everything from scratch
```
db=mbio-rbld
staging=/eupath/data/apiSiteFilesStaging/MicrobiomeDB/5
installApidbSchema --db $db --dropApiDb --allowFailures \
  && installApidbSchema --db $db --dropGUS --allowFailures  \
  && build GUS install -append -installDBSchemaSkipRoles && installApidbSchema --db $db --create \
  && insertUserProjectGroup --projectRelease 56 --firstName Wojtek --lastName Bazant --commit \
  && bld EbrcModelCommon/Model && bld MicrobiomeWorkflow/Main/ && generateFromDatasets MicrobiomeDatasets &&  rm -rf $staging && rm -rf data logs steps backups && registerAllPlugins.pl && workflow -h `pwd` -r
```

### Add a new study
```
workflow -h `pwd` -r -u createLineageTaxonLinkingTable
workflow -h `pwd` -r -u crossStudyCard

bld EbrcModelCommon/Model && bld MicrobiomeWorkflow/Main/ && generateFromDatasets MicrobiomeDatasets
```

### Rerun a study
The cluster runs are skipped when a result file is present under `data/all_results`. Which is good sometimes but not when you want to rerun a study.
So if you do, you need to move the files:

```
study=AnophelesAlbimanus
mkdir -p backup && mv data/all_results/${study}* backup
workflow -h `pwd` -r -u MicrobiomeStudy_${study}_DADA2
workflow -h `pwd` -r -u MicrobiomeStudy_${study}_Humann

bld EbrcModelCommon/Model && bld MicrobiomeWorkflow/Main/ && generateFromDatasets MicrobiomeDatasets
```

### Remove a study

```
study=CaliforniaMosquitoes
workflow -h `pwd` -r -u MicrobiomeStudy_${study}_copyManualDeliveryFiles
```

### Reload microbiome.owl
```
workflow -h `pwd` -r -u microbiomeGlobal.eupathCuratedOntologies
```

### Reload sample details only (if microbiome.owl fine)
```
workflow -h `pwd` -r -u ISASimpleMicrobiome
```

### Workflow dev - change xml, add new params to MicrobiomeStudy class, etc.

Make sure nothing is running. Make sure all results you want to still have in the database afterwards are in `all_results` as files.

Do the big undo:
```
workflow -h `pwd` -r -u beginMicrobiomeStudies
```

Then do the build:
```
bld EbrcModelCommon/Model; bld MicrobiomeWorkflow/Main/ ; generateFromDatasets MicrobiomeDatasets
```

Then do the do:
```
workflow -h `pwd` -r
```

## PMACS environment

### Wojtek's .bash_profile

```
# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

GUS_HOME=$HOME/gus_home

PATH=/project/eupathdblab/workflow-software/bin:$PATH
PATH=$HOME/bin:$PATH

# dada2 scripts for 16s workflow
PATH=$GUS_HOME/bin:$PATH
PATH=$HOME/lib/R-3.6.2/bin:$PATH

# Python installed - humann and stuff
PATH=$HOME/.local/bin:$PATH

# needed for humann
PATH=$HOME/.local/lib/python3.7/site-packages/humann/quantify/glpk-4.55/examples/:$PATH

# nothing for production I think
PERL5LIB=$HOME/perl5/lib/perl5:$PERL5LIB

export PATH
export PERL5LIB
export GUS_HOME

# make sure ctrl + X,ctrl +E in Bash opens a good editor
EDITOR=vi
VISUAL=$EDITOR
export EDITOR
export VISUAL

# needed for Nextflow runner
JAVA_CMD=/usr/lib/jvm/java-1.8.0/bin/java
JAVA_HOME=/usr/lib/jvm/java-1.8.0
export JAVA_CMD
export JAVA_HOME
NXF_JAVA_HOME=/bin/java
export NXF_JAVA_HOME
 
export WD=/project/eupathdblab/workflows/MicrobiomeDB/5/data
```

### 16s 
The 16s workflow runs dada2 scripts using DJob. This requires a $GUS_HOME directory - install DJob on `yew`, and copy it over to PMACS.



### WGS - `humann`
The `humann` workflow relies on custom forks of `humann` (https://github.com/wbazant/humann) and `kneaddata` (https://github.com/wbazant/kneaddata). 
Clone them locally, and install with `pip install .` .

`humann` requires a large number of tools to run. Follow https://github.com/VEuPathDB/humann-nextflow instructions, and if they don't work, fall back to original instructions.

`humann` also requires a number of databases - follow original instructions to get them. They end up in home directory:
```
~/humann_utility/
~/uniref
~/chocophlan
~/kneaddata_databases
~/metacyc-names.txt
```
The `201901` chocoplan version has been used to generate the data currently on the site, I think there have been slightly newer ones.


### WGS - `CORRAL`
Follow installation instructions on https://github.com/wbazant/CORRAL. Feel free to open pull requests against the repository if sometihng doesn't work.

The reference databases for this are provisioned from manual delivery (`/eupath/data/EuPathDB/manualDelivery/MicrobiomeDB/common/EukMarkersReference/EukDetect/7/`) and the workflow copies them to the cluster.

## PMACS commands

### Nextflow workflows
```
bsub -e bsub.e -o bsub.o 'nextflow run VEuPathDB/humann-nextflow -with-trace -c ./nextflow.config -resume | tee tee.out '
bsub -e bsub.e -o bsub.o 'nextflow run wbazant/CORRAL -r main -c ./nextflow.config -with-trace -resume | tee tee.out'
```

### cleaning up
```
find work -type f -size +20M -delete
```

Wojtek got rid of all the .fastq files when he was leaving so the project doesn't get charged for storage.
```
cd /project/eupathdblab/workflows/MicrobiomeDB/5/data
find otuDADA2_* -type f -size +20M -delete
```

# Microbiome workflow for EDA

## Where is the stuff?

```
Root of the workflow
$PROJECT_HOME/MicrobiomeWorkflow/Main/lib/xml/workflowTemplates/microbiomeRootEda.xml

Result files
/eupath/data/EuPathDB/manualDelivery/MicrobiomeDB/common/MicrobiomeStudyEda

Datasets and presenters are together with the main ones, but get an "Eda" prefix:
https://github.com/VEuPathDB/MicrobiomeDatasets/
Each dataset (MicrobiomeStudyEda) says which .owl it needs, and there's also an .owl dataset (MicrobiomeOwlEda).

There's only one .owl in use now,
 `https://github.com/VEuPathDB/ApiCommonData/blob/master/Load/ontology/Microbiome/microbiome_human_only.owl`
The deal for changing the file was that Wojtek requested changes to the conversion file https://github.com/VEuPathDB/ApiCommonData/blob/master/Load/ontology/Microbiome/doc/Microbiome_human_only_conversion.csv , and Jie made the .owl.


The sample details files are in https://github.com/VEuPathDB/ApiCommonMetadataRepository/tree/master/ISA/metadata/MBSTDY0021 - one .txt and one .xml per study. Don't edit the .xml files, edit https://github.com/VEuPathDB/ApiCommonMetadataRepository/blob/master/scripts/make_eda_Xmls.pl.


```

## What is the workflow like?
Super chill. Data loading will be a breeze when MicrobiomeDB is "on EDA"!

To add a new study into EDA:
1. run workflows with computations however you like and get the result files, for example: get them from the old workflow
2. pick a moniker `$STUDY` for the study and version `$VERSION` with today's date
3. put all the results in `/eupath/data/EuPathDB/manualDelivery/MicrobiomeDB/common/MicrobiomeStudyEda/$STUDY/$VERSION`
4. add a MicrobiomeStudyEda entry to MicrobiomeDatasets with the new `$STUDY`, `$VERSION`, and .owl (probably: microbiome_human_only.owl)
5. `cd $PROJECT_HOME/ApiCommonMetadataRepository/ISA/metadata/MBSTDY0021/`
6. put sample details under `$STUDY.txt`
7. Edit `$PROJECT_HOME/ApiCommonMetadataRepository/scripts/make_eda_Xmls.pl` and run it to get the appropriate entity graph in `$STUDY.xml`
8. Do some input checks. See: Operations
9. Do the workflow. Nothing depends on all studies as a whole, so no `undo`s needed until something goes wrong!


## Operations

### Input checks
Is the conversion file good? This should be empty:
```
comm -3 \
 <( $PROJECT_HOME/ApiCommonMetadataRepository/scripts/list_variables_in_conversion_file.sh $PROJECT_HOME/ApiCommonData/Load/ontology/Microbiome/doc/Microbiome_human_only_conversion.csv ) \
 <( $PROJECT_HOME/ApiCommonMetadataRepository/scripts/list_variables_in_metadata_dir.sh  $PROJECT_HOME/ApiCommonMetadataRepository/ISA/metadata/MBSTDY0021/ ) \
     | head
```

Is the .owl good? This should be empty:

```
comm -23 \
  <( $PROJECT_HOME/ApiCommonMetadataRepository/scripts/list_variables_in_metadata_dir.sh  $PROJECT_HOME/ApiCommonMetadataRepository/ISA/metadata/MBSTDY0021/ | tr A-Z a-z | sort ) \
  <( perl $PROJECT_HOME/ApiCommonMetadataRepository/scripts/list_variables_in_owl.pl $PROJECT_HOME/ApiCommonData/Load/ontology/Microbiome/microbiome_human_only.owl | sort ) \
  | head
```

Are the result files correctly named? Look at the `mbioResultsFileExtensions` parameter in https://github.com/VEuPathDB/MicrobiomeWorkflow/blob/master/Main/lib/xml/workflowTemplates/microbiomeRootEda.xml, the entity prefixes in `$STUDY.xml`, and your files. The general pattern is $STUDY.<prefix>.<extension>.

Do the result files use correct IDs? Look at the first column of your results file, and the sample ID column (usually: name) - that's how they will be paired up.

## ReFlow commands
TODO!

## Development
### Edit entity graph structure

This needs curation of ontology terms - look at `ISA_2` field in the .owl: `https://github.com/VEuPathDB/ApiCommonData/blob/master/Load/ontology/Microbiome/microbiome_human_only.owl`

It's currently either "Sample" or "Source". Putting repeated measures at its own level is one requirement for this.

Also, get an ontology term for "Participant repeated measure".

Then there are .xml files .e.g: https://github.com/VEuPathDB/ApiCommonMetadataRepository/blob/master/ISA/metadata/MBSTDY0021/BONUS.xml , that configure the entity graph.

The xml says that source for human-only is actually a "Participant", the graph defines what the nodes and edges are, and so on. You can make these files with a master script - https://github.com/VEuPathDB/ApiCommonMetadataRepository/blob/master/scripts/make_eda_Xmls.pl.

Change all of that and reload, and you'll have a different entity graph!

# Miscellaneous

## GUS objects
You can set up your GUS home by using symlinks, and then you can work on a few databases:
```
ln -sv $GUS_HOME/config/gus.config.eda-dev $GUS_HOME/config/gus.config
```
but then you need to:
```
touch $PROJECT_HOME/GusSchema/Definition/config/gus_schema.xml ; bld GUS
```

## ReFlow tooling

### Watch progress
```
watch workflowSummary -h `pwd`
```
### List failed
```
workflow -h `pwd` -s FAILED
```

### Failed -> ready
```
workflowstep -h `pwd` -p % ready
```


