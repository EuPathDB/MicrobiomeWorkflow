package OrthoMCLWorkflow::Main::WorkflowSteps::CreateAndInsertClusterLayoutGraphs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
    my ($self, $test, $undo) = @_;
    
    my $threads = $self->getParamValue('numberOfThreadsToUse');
    my $maxGroupSize = $self->getParamValue('maxGroupSize');

    if ($undo) {
	$self->runCmd($test, "orthomclClusterLayout -undo");
    } else{
	$self->runCmd($test, "orthomclClusterLayout -max $maxGroupSize -task $threads");
    }
}


