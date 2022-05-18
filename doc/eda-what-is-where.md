# EDA- what is where?

![pic](https://static.wikia.nocookie.net/looneytunes/images/7/7a/Hubie%26Bertie.png/revision/latest/scale-to-width-down/250?cb=20190309052602)

In short:
```
# Root of the workflow
$PROJECT_HOME/MicrobiomeWorkflow/Main/lib/xml/workflowTemplates/microbiomeRootEda.xml

# Analysis files - input to EDA loading
/eupath/data/EuPathDB/manualDelivery/MicrobiomeDB/common/MicrobiomeStudyEda

# Workflow directory
/eupath/data/EuPathDB/devWorkflows/MicrobiomeDB/EDAwg

```

Datasets and presenters are together with the main ones, but get an "Eda" prefix:
https://github.com/VEuPathDB/MicrobiomeDatasets/
Each dataset (MicrobiomeStudyEda) says which .owl it needs, and there's also an .owl dataset (MicrobiomeOwlEda).

There's only one .owl in use now,
 `https://github.com/VEuPathDB/ApiCommonData/blob/master/Load/ontology/Microbiome/microbiome_human_only.owl`
The deal for changing the file was that Wojtek requested changes to the conversion file https://github.com/VEuPathDB/ApiCommonData/blob/master/Load/ontology/Microbiome/doc/Microbiome_human_only_conversion.csv , and Jie made the .owl.


The sample details files are in https://github.com/VEuPathDB/ApiCommonMetadataRepository/tree/master/ISA/metadata/MBSTDY0021 - one .txt and one .xml per study. Don't edit the .xml files, edit https://github.com/VEuPathDB/ApiCommonMetadataRepository/blob/master/scripts/make_eda_Xmls.pl.
