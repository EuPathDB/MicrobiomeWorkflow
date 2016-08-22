package OrthoMCLWorkflow::Main::WorkflowSteps::CombineGroupFiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $mappedGroupsFile = $self->getParamValue('mappedGroupsFile');
  my $residualsGroupsFile = $self->getParamValue('residualsGroupsFile');
  my $outputGroupsFile = $self->getParamValue('outputGroupsFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
    $self->runCmd(0, "rm $workflowDataDir/$outputGroupsFile") if -e "$workflowDataDir/$outputGroupsFile";
  } else {
    $self->testInputFile('mappedGroupsFile', "$workflowDataDir/$mappedGroupsFile");
    $self->testInputFile('residualsGroupsFile', "$workflowDataDir/$residualsGroupsFile");

    my $cmd = "orthomclMergeGroupFiles $workflowDataDir/$mappedGroupsFile $workflowDataDir/$residualsGroupsFile $workflowDataDir/$outputGroupsFile";
    $self->runCmd($test, $cmd);
    if ($test) {
      $self->runCmd(0, "touch $workflowDataDir/$outputGroupsFile");
    }

  }
}


