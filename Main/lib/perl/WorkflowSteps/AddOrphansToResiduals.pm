package OrthoMCLWorkflow::Main::WorkflowSteps::AddOrphansToResiduals;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

# input mapped groups file:
#   -  has ref groups (including singletons) plus mapped peripherals
# output "residuals" which are:
#   -  all peripherals that map to ref groups of size 1, 2 or 3, or do not map
#   -  all refs that are in size 1, 2 or 3 groups that have at least 1 mapped periph
# output reduced mapped groups file:
#   - the mapped groups file, stripped of the groups that went into the residuals, and also of all singletons

sub run {
  my ($self, $test, $undo) = @_;

  my $inputReferenceGroupsFile = $self->getParamValue('inputReferenceGroupsFile');
  my $inputMappedGroupsFile = $self->getParamValue('inputMappedGroupsFile');
  my $inputRefFastaFile = $self->getParamValue('inputRefFastaFile');
  my $inputPeriphFastaFile = $self->getParamValue('inputPeriphFastaFile');
  my $inputResidualIdsFile = $self->getParamValue('inputResidualIdsFile');
  my $outputResidualsFastaFile = $self->getParamValue('outputResidualsFastaFile');
  my $outputReducedMappedGroupsFile = $self->getParamValue('outputReducedMappedGroupsFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
    $self->runCmd(0, "rm $workflowDataDir/$outputResidualsFastaFile") if -e "$workflowDataDir/$outputResidualsFastaFile";
  } else {
    $self->testInputFile('inputReferenceGroupsFile', "$workflowDataDir/$inputReferenceGroupsFile");
    $self->testInputFile('inputMappedGroupsFile', "$workflowDataDir/$inputMappedGroupsFile");
    $self->testInputFile('inputRefFastaFile', "$workflowDataDir/$inputRefFastaFile");
    $self->testInputFile('inputPeriphFastaFile', "$workflowDataDir/$inputPeriphFastaFile");
    $self->testInputFile('inputResidualIdsFile', "$workflowDataDir/$inputResidualIdsFile");

    my $cmd = "addOrphansToResiduals $workflowDataDir/$inputReferenceGroupsFile $workflowDataDir/$inputMappedGroupsFile $workflowDataDir/$inputRefFastaFile $workflowDataDir/$inputPeriphFastaFile $workflowDataDir/$inputResidualIdsFile  $workflowDataDir/$outputResidualsFastaFile $workflowDataDir/$outputReducedMappedGroupsFile";
    $self->runCmd($test, $cmd);
    if ($test) {
      $self->runCmd(0, "touch $workflowDataDir/$outputResidualsFastaFile");
      $self->runCmd(0, "touch $workflowDataDir/$outputReducedMappedGroupsFile");
    }

  }
}


