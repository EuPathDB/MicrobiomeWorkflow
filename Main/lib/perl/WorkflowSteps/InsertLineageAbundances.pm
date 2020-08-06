package MicrobiomeWorkflow::Main::WorkflowSteps::InsertLineageAbundances;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $inputPath = join ("/", $self->getWorkflowDataDir(), $self->getParamValue('inputPath'));

    $self->testInputFile('inputPath', $inputPath);
    my $datasetName = $self->getParamValue('datasetName');

    $self->runPlugin($test, $undo, "ApiCommonData::Load::LineageAbundances", "--inputPath $inputPath --datasetName $datasetName");
}
1;
