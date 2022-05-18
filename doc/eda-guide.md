# Microbiome workflow for EDA

![pic](https://static.wikia.nocookie.net/looneytunes/images/a/af/766551BC-31DE-4FDA-BB5E-7ABB65B057ED.png/revision/latest/scale-to-width-down/290?cb=20200323034452)

See [EDA: what is where](eda-what-is-where.md) for paths to directories etc.

```

## What is the workflow like?
Super chill. Data loading will be a breeze when MicrobiomeDB is "on EDA"!

## Adding a new study - step by step guide

To add a new study into EDA:
1. run workflows with computations however you like and get the result files, for example: get them from the old workflow. Verify success and announce it.
2. Get sample detail as .txt from Dan, and correspondingly updated .owl files from Jie. Jie will also pick a moniker for the study, e.g. `Malaysia_Helminth`, when updating the .owl.
3. Do some input checks. Do not make corrections yourself - instead, ask people who gave you the files to make the changes. Details in [EDA sample details doc](eda-sample-details.md).
4. add environment variables to you Bash session: `$STUDY` for the study's moniker and `$VERSION` with today's date 
5. put all the results in `/eupath/data/EuPathDB/manualDelivery/MicrobiomeDB/common/MicrobiomeStudyEda/$STUDY/$VERSION`
6. add a MicrobiomeStudyEda entry to MicrobiomeDatasets with the new `$STUDY`, `$VERSION`, and .owl (probably: microbiome_human_only.owl)
7. `cd $PROJECT_HOME/ApiCommonMetadataRepository/ISA/metadata/MBSTDY0021/`
8. put sample details under `$STUDY.txt`
9. Edit `$PROJECT_HOME/ApiCommonMetadataRepository/scripts/make_eda_Xmls.pl` and run it to get the appropriate entity graph in `$STUDY.xml`
11. Do the workflow. Nothing depends on all studies as a whole, but you might need to `undo` when you update an .owl. See [EDA ReFlow commands])(eda-reflow.md)


See a worked example at https://github.com/VEuPathDB/MicrobiomeWorkflow/issues/19 , with various issues encountered and their fixes.
