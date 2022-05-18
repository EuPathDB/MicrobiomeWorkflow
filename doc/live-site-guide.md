# Production guide for the live site

![pic](https://static.wikia.nocookie.net/looneytunes/images/1/13/Looneytunes-roadrunner.gif/revision/latest/scale-to-width-down/212?cb=20130303015934)

To prepare and run an analysis for a new study, follow either [New study - 16s dataset](16s-guide.md) or [New study - WGS](wgs-guide.md).

Then do a combination of workflow ops - you can copy-paste the commands [live site ReFlow doc](live-site-reflow.md), PMACS ops [PMACS operations doc](pmacs-operations.md), and getting sample details right [sample details doc](live-site-sample-details.md).

## Workflow overview

Overall there is a following structure to the workflow:

1. Stuff at the beginning, rarely touched
2. `beginMicrobiomeStudies` which is the starting point for computations + result loading
3. computations, they only run if the results are not present
4. loading the results per study `insertMBioResults_${name}`
5. joint steps, `createLineageTaxonLinkingTable` and `crossStudyCard`
6. loading the microbiome.owl: `eupathCuratedOntologies` subgraph
7. loading sample details: `ISASimpleMicrobiome` steps
8. tuning manager
9. download files

Open the [root xml](https://github.com/VEuPathDB/MicrobiomeWorkflow/blob/master/Main/lib/xml/workflowTemplates/microbiomeRoot.xml) and make sure you can identify the steps from this outline, in case you need to know more! 

## What is the workflow graph like?

The workflow is great for running analyses and getting resultsfor studies Convenience features include:
- beginMicrobiomeStudies undoes everything related to running computations
- all computations write their final results to one directory, `all_results`
- all computations have a "skip if file" based on `all_results` dir contents


On the other hand, loading sample details and getting the site to show up is a pain. You need to get a lot of things right, and then load everything - which takes about three hours - and see if it shows up. There's a manual step of adding CORRAL results. 

See [Live site sample details preparation](live-site-sample-details.md) for that part of the process.

