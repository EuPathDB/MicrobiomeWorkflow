# Code

![pic](https://static.wikia.nocookie.net/looneytunes/images/4/47/Screenshot_20210806-153017.png/revision/latest?cb=20210806203306)

Here's a list of places with code written for MicrobiomeDB:

1. The workflow graph is in https://github.com/VEuPathDB/MicrobiomeWorkflow/tree/master/Main/lib/xml and also https://github.com/VEuPathDB/EbrcModelCommon/blob/master/Model/lib/xml/datasetClass/classes.xml.
2. The individual steps are in https://github.com/VEuPathDB/MicrobiomeWorkflow/tree/master/Main/lib/perl, they inherit from common steps in https://github.com/VEuPathDB/ApiCommonWorkflow/ and https://github.com/VEuPathDB/ReFlow/.
3. The Perl code for loading the results is mostly in https://github.com/VEuPathDB/ApiCommonData - our bits start with "MBio" in https://github.com/VEuPathDB/ApiCommonData/tree/master/Load/lib/perl and the unit tests are in https://github.com/VEuPathDB/ApiCommonData/tree/master/Load/t.
4. The ontology parts - common, but received a lot of work to accomodate MicrobiomeDB and later EDA - start with CBIL::ISA::InvestigationSimple, and other stuff in https://github.com/VEuPathDB/CBIL/tree/master/ISA.
5. The 16s workflow is the task of running DADA2 in DJob - https://github.com/VEuPathDB/DJob/tree/master/DistribJobTasks/bin/dada2 for individual scripts, and there's also https://github.com/VEuPathDB/DJob/blob/master/DistribJobTasks/lib/perl/ASVTableTask.pm that calls out to them.
6. There's no one WGS workflow, there are two separate tasks: `humann` - https://github.com/VEuPathDB/humann-nextflow - and `CORRAL` on https://github.com/wbazant/CORRAL/
7. The `humann` workflow relies on custom forks of `humann` (https://github.com/wbazant/humann) and `kneaddata` (https://github.com/wbazant/kneaddata). Not much is done with the results, except decorating with taxon IDs and loading appropriately.

