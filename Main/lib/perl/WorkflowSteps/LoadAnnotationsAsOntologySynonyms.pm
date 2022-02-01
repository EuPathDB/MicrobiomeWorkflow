package MicrobiomeWorkflow::Main::WorkflowSteps::LoadAnnotationsAsOntologySynonyms;

# inspired by
# package ApiCommonWorkflow::Main::WorkflowSteps::UpdateOntologySynonym


@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;

use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
    my ($self, $test, $undo) = @_;

    my @args = ();
    push @args, "--attributesFile", join ("/", $self->getWorkflowDataDir(), $self->getParamValue("attributesFile"));
    push @args, "--extDbRlsSpec", "'" . $self->getParamValue('extDbRlsSpec') . "'";
  
    $self->runPlugin($test, $undo, "GUS::Supported::Plugin::InsertOntologySynonymAttributes", join(" ", @args));
}

1;


