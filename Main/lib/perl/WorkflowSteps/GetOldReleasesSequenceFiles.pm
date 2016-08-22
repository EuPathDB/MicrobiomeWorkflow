package OrthoMCLWorkflow::Main::WorkflowSteps::GetOldReleasesSequenceFiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # iterate through previous releases download dirs
  # for each release, find seq fasta file
  # in outputDir make dir for that release
  # read seq file.  for each taxon write out a file into the release's output dir, gzip it.


  my $inputDir = $self->getParamValue('inputDir');  # download site dir including all previous releases (but not the one we are building)
  my $outputDir = $self->getParamValue('outputDir'); # where to put th 

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $targetDir = "$workflowDataDir/$outputDir";

  $self->testInputFile('inputDir', $inputDir);

  if ($undo) {
    $self->runCmd(0,"rm -r $targetDir");
  } else {
    if ($test) {
      $self->runCmd(0, "mkdir $targetDir");
    } else {
      $self->runCmd($test, "orthomclGetOldRlsSeqFiles $inputDir $targetDir");
    }
  }
}
