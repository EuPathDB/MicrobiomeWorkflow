package OrthoMCLWorkflow::Main::WorkflowSteps::MakeMuscleTaskInputDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::MakeTaskInputDir);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::MakeTaskInputDir;

sub testMode {
    my ($self, $workflowDataDir) = @_;

    my $fastaFilesDir = $self->getParamValue('fastaFilesDir');
    $self->testInputFile('fastaFilesDir', "$workflowDataDir/$fastaFilesDir");
}

sub getTaskPropFileContents {
    my ($self, $clusterWorkflowDataDir) = @_;
    # get parameters
    my $fastaFilesDir = $self->getParamValue('fastaFilesDir');
    my $binDir = $self->getConfig('muscleBinDir');
    return 
"inputFileDir=$clusterWorkflowDataDir/$fastaFilesDir
 muscleBinDir=$binDir
";
}

sub getDistribJobTask {
  return "DJob::DistribJobTasks::MsaTask";
}
