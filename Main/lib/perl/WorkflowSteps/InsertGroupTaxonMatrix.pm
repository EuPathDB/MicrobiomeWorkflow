package OrthoMCLWorkflow::Main::WorkflowSteps::InsertGroupTaxonMatrix;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  $self->runPlugin($test, $undo, "OrthoMCLData::Load::Plugin::InsertOrthomclGroupTaxonMatrix", "");

}
