package OrthoMCLWorkflow::Main::WorkflowSteps::MapPeripheralsToGroups;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $referenceGroupsFile = $self->getParamValue('inputReferenceGroupsFile');
  my $outputGroupsFile = $self->getParamValue('outputGroupsFile');
  my $outputResidualsFile = $self->getParamValue('outputResidualsFile');
  my $inputSimilarSequencesTable = $self->getParamValue('inputSimilarSequencesTable');

  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
    $self->runCmd(0, "rm $workflowDataDir/$outputGroupsFile") if -e "$workflowDataDir/$outputGroupsFile";
    $self->runCmd(0, "rm $workflowDataDir/$outputResidualsFile") if -e "$workflowDataDir/$outputResidualsFile";
  } else {
    $self->testInputFile('referenceGroupsFile', "$workflowDataDir/$referenceGroupsFile");

    my $cmd = "augmentRepresentativeGroups $workflowDataDir/$referenceGroupsFile $workflowDataDir/$outputGroupsFile $workflowDataDir/$outputResidualsFile $inputSimilarSequencesTable";
    $self->runCmd($test, $cmd);
    if ($test) {
      $self->runCmd(0, "touch $workflowDataDir/$outputGroupsFile");
      $self->runCmd(0, "touch $workflowDataDir/$outputResidualsFile");
    }

  }
}


