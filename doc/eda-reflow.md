# EDA ReFlow operations

![pic](https://static.wikia.nocookie.net/looneytunes/images/3/33/Prissy_300.gif/revision/latest/scale-to-width-down/238?cb=20110828155656)


## ReFlow commands

This is our biggest undo, which needs to happen when the .owl changes, because everything depends on it.
```
workflow -h `pwd` -r -u beginMicrobiomeOwls
```

If you want to reload all studies but keep the .owls do this one:
```
workflow -h `pwd` -r -u beginCopyStudies
```

To add new studies, no undos are needed - add them to MicrobiomeDatasets, make the workflow graph bigger, and rerun.

I think this is the comprehensive `bld` command which will always work:
```

bld CBIL/ISA && bld ApiCommonData/Load && bld ApiCommonMetadataRepository/ISA && bld EbrcModelCommon/Model && bld MicrobiomeWorkflow/Main/ && generateFromDatasets MicrobiomeDatasets
```

If sample details or manual delivery files change, undo up to here: 
```
study=MORDOR_metatranscriptome
workflow -h `pwd` -r -u MicrobiomeStudy_${study}_copyManualDeliveryAndInvestigationFiles
```

## Development
### Edit entity graph structure

This needs curation of ontology terms - look at `ISA_2` field in the .owl: `https://github.com/VEuPathDB/ApiCommonData/blob/master/Load/ontology/Microbiome/microbiome_human_only.owl`

It's currently either "Sample" or "Source". Putting repeated measures at its own level is one requirement for this.

Also, get an ontology term for "Participant repeated measure".

Then there are .xml files .e.g: https://github.com/VEuPathDB/ApiCommonMetadataRepository/blob/master/ISA/metadata/MBSTDY0021/BONUS.xml , that configure the entity graph.

The xml says that source for human-only is actually a "Participant", the graph defines what the nodes and edges are, and so on. You can make these files with a master script - https://github.com/VEuPathDB/ApiCommonMetadataRepository/blob/master/scripts/make_eda_Xmls.pl.

Change all of that and reload, and you'll have a different entity graph!

### Start from scratch


```
db=rm41910
staging=/eupath/data/apiSiteFilesStaging//MicrobiomeDB/EDAwg
cd /eupath/data/EuPathDB/devWorkflows/MicrobiomeDB/EDAwg
installApidbSchema --db $db --dropApiDb --allowFailures <<< "$db
" \
  && installApidbSchema --db $db --dropGUS --allowFailures  <<< "$db
" \
  && build GUS install -append -installDBSchemaSkipRoles && installApidbSchema --db $db --create \
  && insertUserProjectGroup --projectRelease 57 --firstName Wojtek --lastName Bazant --commit \
  && bld EbrcModelCommon/Model && bld MicrobiomeWorkflow/Main/ && generateFromDatasets MicrobiomeDatasets && rm -rf $staging && rm -rf data logs steps backups && registerAllPlugins.pl && workflow -h `pwd` -r
```

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
