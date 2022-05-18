# EDA sample details

![pic](https://static.wikia.nocookie.net/looneytunes/images/3/32/RalphWolf.jpg/revision/latest?cb=20211031014003)

You should start from an initially prepared sample details file. See the [new study sample details doc](sample-details-guide.md) for details.

Then copy and adjust it for EDA as part of following [the main guide](eda-guide.md).

## Input checks

This is the main folder:
```
$PROJECT_HOME/ApiCommonMetadataRepository/ISA/metadata/MBSTDY0021/
```
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

### Summarise file contents

Really handy if you're messing with file contents, because you can compare the output before and after:
```
f=$PROJECT_HOME/ApiCommonMetadataRepository/ISA/metadata/MBSTDY0021/Malaysia_Helminth.txt
owl=$PROJECT_HOME/ApiCommonData/Load/ontology/Microbiome/microbiome_human_only.owl

$PROJECT_HOME/ApiCommonMetadataRepository/scripts/summarise_ISA.pl $f $owl
```

Example - remove a column:
```
transpose $f | grep -v env_feature | transpose > $f.1
diff <( $PROJECT_HOME/ApiCommonMetadataRepository/scripts/summarise_ISA.pl $f $owl) <( $PROJECT_HOME/ApiCommonMetadataRepository/scripts/summarise_ISA.pl $f.1 $owl )
mv $f.1 $f

```
