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

## PMACS cluster
### Humann
```
bsub -e controller.e -o controller.o nextflow run VEuPathDB/humann-nextflow -with-trace -c ./nextflow.config -resume
```
humann
~/kneaddata_databases
~/lib/Trimmomatic-0.39
