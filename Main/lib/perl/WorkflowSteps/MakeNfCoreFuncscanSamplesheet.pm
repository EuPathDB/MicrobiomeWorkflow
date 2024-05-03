package MicrobiomeWorkflow::Main::WorkflowSteps::MakeNfCoreFuncscanSamplesheet;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $sampleToFastqPath = join("/", $self->getWorkflowDataDir(), $self->getParamValue("analysisDir"), $self->getParamValue("sampleToFastqFileName"));
  my $magAnalysisDir = join("/", $self->getWorkflowDataDir(), $self->getParamValue("magAnalysisDir"));
  my $samplesheetPath = join("/", $self->getWorkflowDataDir(), $self->getParamValue("analysisDir"), "samplesheet.csv");

  if ($undo) {
    $self->runCmd(0,"rm -rf $configPath");
  } else {
    open(F, ">", $samplesheetPath) or die "$! :Can't open config file '$samplesheetPath' for writing";

    # TODO write the header here, then
    # loop through the sampleToFastq file and get sample names
    # for each sample, write a row to the samplesheet that points to the associated mag output file
    close(F);

    ## remove the sampleToFastq file
    $self->runCmd(0,"rm -rf $sampleToFastqPath"); ## TODO make sure we want to do this, vs ignore its existence
  }
}

1;