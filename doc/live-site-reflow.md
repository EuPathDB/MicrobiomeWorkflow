# ReFlow guide for the live site production

![pic](https://static.wikia.nocookie.net/looneytunes/images/2/2c/Sylvester_the_Cat_%28SVG%29.svg/revision/latest/scale-to-width-down/172?cb=20220111145029)

Copy commands from here.

## Current workflow directory

Here:
```
/eupath/data/EuPathDB/workflows/MicrobiomeDB/5/
```


## The big `bld` command
 
I think this is the minimal `bld` command which will always get all the code needed:
```

bld CBIL/ISA && bld ApiCommonData/Load && bld ApiCommonMetadataRepository/ISA && bld EbrcModelCommon/Model && bld MicrobiomeWorkflow/Main/ && generateFromDatasets MicrobiomeDatasets
```

## UNDOs required for tasks

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

## Workflow dev - change xml, add new params to MicrobiomeStudy class, etc.

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
