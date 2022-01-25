# MicrobiomeWorkflow notes

## ReFlow: doings, undoings, and redoings

### Everything from scratch
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
The cluster runs are skipped when a result  file is present under `data/all_results`. Which is good sometimes but not when you want to rerun a study.
So if you do, you need to move the files.
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

### Workflow dev - add new params to MicrobiomeStudy class, etc.
This is kind of necessary:
```
workflow -h `pwd` -r -u beginMicrobiomeStudies
```
When you redo it will skip based on files instead of resubmitting, which is very good.

## Ops
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
## PMACS cluster
### Humann
```
bsub -e bsub.e -o bsub.o 'nextflow run VEuPathDB/humann-nextflow -with-trace -c ./nextflow.config -resume | tee tee.out '
```



humann
~/kneaddata_databases
~/lib/Trimmomatic-0.39

### EukDetect
```
bsub -e bsub.e -o bsub.o 'nextflow run wbazant/marker-alignments-nextflow -r main -c ./nextflow.config -with-trace -resume | tee tee.out'
```

### cleaning up
```
find work -type f -size +20M -delete
```
## Sample detail files

### summary of a file
```
cd $PROJECT_HOME/ApiCommonMetadataRepository

./scripts/summarise_ISA.pl ./ISA/metadata/MBSTDY0020/DIABIMMUNE_WGS.txt ./ISA/config/ontologyMappingsMicrobiome.xml 
```
These are very useful for making changes, you can diff them before and after the change.

### test file
```
cd $PROJECT_HOME/ApiCommonMetadataRepository

PERL5LIB=$GUS_HOME/lib/perl:PERL5LIB SPARQLPATH=scripts/lib/ApiCommonData/Load/lib/SPARQL/ perl ./scripts/microbiomedb.t
```
The test is useful for enforcing our SOPs about what sample details should be present as a minimum.

We don't follow the SOPs completely, but they're helpful anyway. The test also fails if the mapping isn't complete.

### EDA

Is the conversion file good? This should be empty:
```
comm -3 \
 <( $PROJECT_HOME/ApiCommonMetadataRepository/scripts/list_variables_in_conversion_file.sh $PROJECT_HOME/ApiCommonData/Load/ontology/Microbiome/doc/Microbiome_human_only_conversion.csv ) \
 <( $PROJECT_HOME/ApiCommonMetadataRepository/scripts/list_variables_in_metadata_dir.sh  $PROJECT_HOME/ApiCommonMetadataRepository/ISA/metadata/MBSTDY0021/ ) \
     | head
```

Is the owl good? This should be empty:
```
comm -23 \
  <( $PROJECT_HOME/ApiCommonMetadataRepository/scripts/list_variables_in_metadata_dir.sh  $PROJECT_HOME/ApiCommonMetadataRepository/ISA/metadata/MBSTDY0021/ | tr A-Z a-z | sort ) \
  <( perl $PROJECT_HOME/ApiCommonMetadataRepository/scripts/list_variables_in_owl.pl $PROJECT_HOME/ApiCommonData/Load/ontology/Microbiome/microbiome_human_only.owl | sort ) \
  | head
```

## Overview of where what is
(10 2021)
The workflow graph is in https://github.com/VEuPathDB/MicrobiomeWorkflow/tree/master/Main/lib/xml and also https://github.com/VEuPathDB/EbrcModelCommon/blob/master/Model/lib/xml/datasetClass/classes.xml.
The individual steps are in https://github.com/VEuPathDB/MicrobiomeWorkflow/tree/master/Main/lib/perl, they inherit from on steps in https://github.com/VEuPathDB/ApiCommonWorkflow/ and https://github.com/VEuPathDB/ReFlow/.
The Perl code for loading the results is mostly in https://github.com/VEuPathDB/ApiCommonData - our bits start with "MBio" in https://github.com/VEuPathDB/ApiCommonData/tree/master/Load/lib/perl and the unit tests are in https://github.com/VEuPathDB/ApiCommonData/tree/master/Load/t. The ontology parts rely on stuff in https://github.com/VEuPathDB/CBIL/tree/master/ISA.
The 16s workflow is the task of running DADA2 in DJob - https://github.com/VEuPathDB/DJob/tree/master/DistribJobTasks/bin/dada2 for individual scripts, and there's also https://github.com/VEuPathDB/DJob/blob/master/DistribJobTasks/lib/perl/ASVTableTask.pm that calls out to them.
There's no one WGS workflow, there are two separate tasks (for humann and eukdetect), the pipeline for humann "graduated" to be on the VEuPathDB github - https://github.com/VEuPathDB/humann-nextflow - and the one for EukDetect is not production yet so it's https://github.com/wbazant/marker-alignments-nextflow.

## What to bld, how, and when

### GUS objects
You can switch between configs by using symlinks, and then you can work on a few databases:
```
ln -sv $GUS_HOME/config/gus.config.eda-dev $GUS_HOME/config/gus.config
```
but then you need to:
```
touch $PROJECT_HOME/GusSchema/Definition/config/gus_schema.xml ; bld GUS
```

### From scratch
I did this in Jan 2020 when I was redeveloping the whole thing and started from scratch every time.

```
installApidbSchema --db mbio-rbld --dropApiDb --allowFailures && installApidbSchema --db mbio-rbld --dropGUS --allowFailures  && build GUS install -append -installDBSchemaSkipRoles && installApidbSchema --db mbio-rbld --create && bld EbrcModelCommon/Model && bld MicrobiomeWorkflow/Main/ && generateFromDatasets MicrobiomeDatasets &&  rm -rf /eupath/data/apiSiteFilesStaging/MicrobiomeDB/5 && rm -rf data logs steps backups 


&& registerAllPlugins.pl && workflow -h `pwd` -r
```

### When MicrobiomeWorkflow XML graph changes
Make sure nothing is running. Undo stuff you are changing. Change the code:
```
bld EbrcModelCommon/Model; bld MicrobiomeWorkflow/Main/ ; generateFromDatasets MicrobiomeDatasets
```
