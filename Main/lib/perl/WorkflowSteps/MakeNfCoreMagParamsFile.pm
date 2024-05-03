package MicrobiomeWorkflow::Main::WorkflowSteps::MakeNfCoreMagParamsFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $paramsFilePath = join("/", $self->getWorkflowDataDir(), $self->getParamValue("analysisDir"), "nf-params.json");
  my $samplesheetPath = join("/", $self->getWorkflowDataDir(), $self->getParamValue("analysisDir"), "samplesheet.csv");
  my $krakenDBPath = join("/", $self->getWorkflowDataDir(), $self->getParamValue("krakenDBPath"));

  ## TODO compare these args to what i tested on pmacs and make sure i didnt miss anything
  ## TODO figure out for sure which of these ref dbs we need and update them

  if ($undo) {
    $self->runCmd(0,"rm -rf $configPath");
  } else {
    open(F, ">", $paramsFilePath) or die "$! :Can't open config file '$paramsFilePath' for writing";

    print F
"
{
    \"input\": \"$samplesheetPath\",
    \"outdir\": \"out\",
    \"kraken2_db\": \"$krakenDBPath\",
    \"cat_db\": \"TODO\",
    \"gtdb_db\": \"TODO\",
    \"gtdb_mash\": \"TODO\",
    \"skip_spades\": true,
    \"skip_spadeshybrid\": true,
    \"run_virus_identification\": true,
    \"skip_concoct\": true,
    \"metaeuk_db\": \"TODO\",
    \"busco_db\": \"TODO\",
    \"checkm_db\": \"TODO\",
    \"gunc_db\": \"TODO\"
}
";

    close(F);
  }
}

1;

