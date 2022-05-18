# Live site sample details

![pic](https://static.wikia.nocookie.net/looneytunes/images/f/fd/Rapid_Dave.jpg/revision/latest/scale-to-width-down/360?cb=20140408165554)

You should start with an initially prepared sample details file from Dan. See the [new study sample details doc](sample-details-guide.md) for details.

You also need a `microbiome.owl` and the `ontologyMappingsMicrobiome.xml` file from Jie.

To prepare the sample details for the live site:

1. [Do checks](#do-checks)
2. [Add CORRAL results to sample details](#add-corral-results-to-sample-details) if WGS
3. Try to load - [ReFlow live site doc](live-site-reflow.md)
4. [If the site does not work, troubleshoot](#troubleshoot)

## Do checks

### Produce summary of a sample details file

```
cd $PROJECT_HOME/ApiCommonMetadataRepository

./scripts/summarise_ISA.pl ./ISA/metadata/MBSTDY0020/DIABIMMUNE_WGS.txt ./ISA/config/ontologyMappingsMicrobiome.xml 
```

These summaries are very useful for making changes, because you can diff the outputs before and after the change.

## Run assertions on the file

```
cd $PROJECT_HOME/ApiCommonMetadataRepository

PERL5LIB=$GUS_HOME/lib/perl:PERL5LIB SPARQLPATH=scripts/lib/ApiCommonData/Load/lib/SPARQL/ perl ./scripts/microbiomedb.t
```

The test is useful for enforcing our SOPs about what sample details should be present - if `env_feature` isn't present the cross study query won't work correctly, everything else is for consistency.

We don't follow the SOPs completely, but they're helpful to an extent. The test also fails if the mapping isn't complete.

## Add CORRAL results to sample details

You need to start with a vaguely good TSV + ontology mappings + .owl, and then modify them, so that they include the CORRAL results. The versions without this step applied are in the source control, and get the results added on top.

This program takes care of the sample details:

```
$PROJECT_HOME/MicrobiomeWorkflow/Main/scripts/add_eukdetect_terms_to_sample_details.sh
```

This program produces stanzas that you'll need to paste into microbiome.owl and ontologyMappingsMicrobiome.xml:

```
/home/wbazant/project_home/MicrobiomeWorkflow/Main/scripts/extend_owl.pl
```

## Troubleshoot

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


