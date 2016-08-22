package OrthoMCLWorkflow::Main::WorkflowSteps::InsertAliases;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
    my ($self, $test, $undo) = @_;

    my $workflowDataDir = $self->getWorkflowDataDir();

    my $externalDatabase = $self->getParamValue('externalDatabase');
    my $extDbVer = $self->getExtDbVersion($test, $externalDatabase);
    my $aliasesFile = $self->getParamValue('inputMappingFile');
    my $fileFullPath = "$workflowDataDir/$aliasesFile";

    my $args = "--DbRefMappingFile $fileFullPath --extDbName $externalDatabase --extDbReleaseNumber $extDbVer --columnSpec 'primary_identifier,remark' --tableName AASequenceDbRef";

    $self->testInputFile('aliasesFile', "$fileFullPath");
    $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertDBxRefs", $args);

}
