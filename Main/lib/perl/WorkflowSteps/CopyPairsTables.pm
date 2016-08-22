package OrthoMCLWorkflow::Main::WorkflowSteps::CopyPairsTables;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
    my ($self, $test, $undo) = @_;

    my $workflowDataDir = $self->getWorkflowDataDir();

    my $fromSuffix = $self->getParamValue('fromSuffix');
    my $toSuffix = $self->getParamValue('toSuffix');

    my $undoFlag = $undo? "-undo" : "";
    $self->runCmd($test, "orthomclCopyPairsTables '$fromSuffix' '$toSuffix' $undoFlag");
}
