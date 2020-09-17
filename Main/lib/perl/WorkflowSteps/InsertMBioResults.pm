package MicrobiomeWorkflow::Main::WorkflowSteps::InsertMBioResults;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my @args = ("--datasetName", $self->getParamValue("datasetName"));
    if($self->getBooleanParamValue("insertAmplicon")){
       push @args, "--ampliconTaxaPath", join ("/", $self->getWorkflowDataDir(), $self->getParamValue("ampliconTaxaPath"));
    }
    if($self->getBooleanParamValue("insertWGS")){
       push @args, "--wgsTaxaPath", join ("/", $self->getWorkflowDataDir(), $self->getParamValue("wgsTaxaPath"));
       push @args, "--pathwayAbundancesPath", join ("/", $self->getWorkflowDataDir(), $self->getParamValue("pathwayAbundancesPath"));
       push @args, "--pathwayCoveragesPath", join ("/", $self->getWorkflowDataDir(), $self->getParamValue("pathwayCoveragesPath"));
       push @args, "--level4ECsPath", join ("/", $self->getWorkflowDataDir(), $self->getParamValue("level4ECsPath"));
    }
    $self->runPlugin($test, $undo, "ApiCommonData::Load::MBioResults", join(" ", @args));
}
1;
