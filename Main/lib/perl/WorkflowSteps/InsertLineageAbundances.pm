package MicrobiomeWorkflow::Main::WorkflowSteps::InsertLineageAbundances;

use strict;
use warnings;
use parent ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $inputPath = join ("/", $self->getWorkflowDataDir(), $self->getParamValue('inputPath'));

    $self->testInputFile('inputPath', $inputPath);
    my $datasetName = $self->getParamValue('datasetName');

    $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::LineageAbundances", "--inputPath $inputPath --datasetName $datasetName");
}
1;
