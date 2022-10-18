package MicrobiomeWorkflow::Main::WorkflowSteps::MBioInsertEntityGraph;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use File::Basename;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $mbioResultsDir = join ("/", $self->getWorkflowDataDir(), $self->getParamValue("mbioResultsDir"));
    my $datasetDir = dirname($mbioResultsDir);
    my @args = ();
    push @args, "--investigationFile", join ("/", $self->getWorkflowDataDir(), $self->getParamValue("investigationFile"));
    push @args, "--sampleDetailsFile", join ("/", $self->getWorkflowDataDir(), $self->getParamValue("sampleDetailsFile"));
    push @args, "--ontologyMappingFile", join ("/", $self->getWorkflowDataDir(), $self->getParamValue("ontologyMappingFile"));
    push @args, "--ontologyMappingOverrideFile", join ("/", $datasetDir, "final", "ontologyMapping.xml");
    push @args, "--valueMappingFile", join ("/",  $datasetDir, "final", "valueMap.txt");
    push @args, "--mbioResultsDir", join ("/", $self->getWorkflowDataDir(), $self->getParamValue("mbioResultsDir"));
    push @args, "--mbioResultsFileExtensions", $self->getParamValue("mbioResultsFileExtensions");
    push @args, "--extDbRlsSpec", "'" . $self->getParamValue("extDbRlsSpec") . "'";
    push @args, "--schema", $self->getParamValue("schema");
    push @args, "--dieOnFirstError", $self->getParamValue("dieOnFirstError");
    $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::MBioInsertEntityGraph", join(" ", @args));
}
1;
