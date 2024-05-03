package MicrobiomeWorkflow::Main::WorkflowSteps::MakeNfCoreMagSamplesheet;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $sampleToFastqPath = join("/", $self->getWorkflowDataDir(), $self->getParamValue("analysisDir"), $self->getParamValue("sampleToFastqFileName"));
  my $samplesheetPath = join("/", $self->getWorkflowDataDir(), $self->getParamValue("analysisDir"), "samplesheet.csv");

  if ($undo) {
    $self->runCmd(0,"rm -rf $configPath");
  } else {
    open(F, ">", $samplesheetPath) or die "$! :Can't open config file '$samplesheetPath' for writing";

    # TODO write the header here, then
    # loop through the sampleToFastq file and reformat rows
    # write out the reformatted rows to the samplesheet
    # i need to go look at these two files yet to see what needs doing here

    close(F);

    ## remove the sampleToFastq file
    $self->runCmd(0,"rm -rf $sampleToFastqPath");
  }
}

1;

