package MicrobiomeWorkflow::Main::WorkflowSteps::MakeNfCoreFuncscanParamsFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $paramsFilePath = join("/", $self->getWorkflowDataDir(), $self->getParamValue("analysisDir"), "nf-params.json");
  my $samplesheetPath = join("/", $self->getWorkflowDataDir(), $self->getParamValue("analysisDir"), "samplesheet.csv");

  ## TODO sort all these ref dbs, and double check which ones i need. 
  ## TODO compare these args to what i tested on pmacs and make sure i didnt miss anything

  if ($undo) {
    $self->runCmd(0,"rm -rf $configPath");
  } else {
    open(F, ">", $paramsFilePath) or die "$! :Can't open config file '$paramsFilePath' for writing";

    print F
"
{
    \"input\": \"$samplesheetPath\",
    \"outdir\": \"out\",
    \"run_amp_screening\": true,
    \"run_arg_screening\": true,
    \"run_bgc_screening\": true,
    \"amp_hmmsearch_models\": \"TODO\",
    \"amp_ampcombi_db\": \"TODO\",
    \"arg_amrfinderplus_db\": \"TODO\",
    \"arg_deeparg_data\": \"TODO\",
    \"bgc_antismash_databases\": \"TODO\",
    \"bgc_deepbgc_database\": \"TODO\",
    \"bgc_hmmsearch_models\": \"TODO\"
}
";

    close(F);
  }
}

1;

