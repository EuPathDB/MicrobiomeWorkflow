package MicrobiomeWorkflow::Main::WorkflowSteps::MBioInsertEntityGraph;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my @args = ();
    push @args, "--investigationFile", join ("/", $self->getWorkflowDataDir(), $self->getParamValue("investigationFile"));
    push @args, "--ontologyMappingFile", join ("/", $self->getWorkflowDataDir(), $self->getParamValue("ontologyMappingFile"));
    push @args, "--mbioResultsDir", join ("/", $self->getWorkflowDataDir(), $self->getParamValue("mbioResultsDir"));
    push @args, "--mbioResultsFileExtensions", $self->getParamValue("mbioResultsFileExtensions");
    push @args, "--extDbRlsSpec", "'" . $self->getParamValue("extDbRlsSpec") . "'";
    push @args, "--schema", $self->getParamValue("schema");
    $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::MBioInsertEntityGraph", join(" ", @args));
}
1;
