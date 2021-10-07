# MicrobiomeWorkflow notes

## ReFlow: doings, undoings, and redoings
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

## PMACS cluster
### Humann
```
bsub -e controller.e -o controller.o nextflow run VEuPathDB/humann-nextflow -with-trace -c ./nextflow.config -resume
```
humann
~/kneaddata_databases
~/lib/Trimmomatic-0.39


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


## Overview of where what is
(10 2021)
The workflow graph is in https://github.com/VEuPathDB/MicrobiomeWorkflow/tree/master/Main/lib/xml and also https://github.com/VEuPathDB/EbrcModelCommon/blob/master/Model/lib/xml/datasetClass/classes.xml.
The individual steps are in https://github.com/VEuPathDB/MicrobiomeWorkflow/tree/master/Main/lib/perl, they inherit from on steps in https://github.com/VEuPathDB/ApiCommonWorkflow/ and https://github.com/VEuPathDB/ReFlow/.
The Perl code for loading the results is mostly in https://github.com/VEuPathDB/ApiCommonData - our bits start with "MBio" in https://github.com/VEuPathDB/ApiCommonData/tree/master/Load/lib/perl and the unit tests are in https://github.com/VEuPathDB/ApiCommonData/tree/master/Load/t. The ontology parts rely on stuff in https://github.com/VEuPathDB/CBIL/tree/master/ISA.
The 16s workflow is the task of running DADA2 in DJob - https://github.com/VEuPathDB/DJob/tree/master/DistribJobTasks/bin/dada2 for individual scripts, and there's also https://github.com/VEuPathDB/DJob/blob/master/DistribJobTasks/lib/perl/ASVTableTask.pm that calls out to them.
There's no one WGS workflow, there are two separate tasks (for humann and eukdetect), the pipeline for humann "graduated" to be on the VEuPathDB github - https://github.com/VEuPathDB/humann-nextflow - and the one for EukDetect is not production yet so it's https://github.com/wbazant/marker-alignments-nextflow.
