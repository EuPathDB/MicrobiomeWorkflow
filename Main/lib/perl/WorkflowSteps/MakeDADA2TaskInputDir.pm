package MicrobiomeWorkflow::Main::WorkflowSteps::MakeDADA2TaskInputDir;

@ISA = (MicrobiomeWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use MicrobiomeWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameter values
  my $taskInputDir = $self->getParamValue("taskInputDir");
  my $fastqDir = $self->getParamValue("fastqDir");
  my $multiplexed = $self->getBooleanParamValue("multiplexed");
  my $keepNode = $self->getParamValue("keepNode");
  my $barcodesType = $self->getParamValue("barcodesType");
  my $samplesInfoFile = $self->getParamValue("samplesInfoFile");
  my $isPaired = $self->getBooleanParamValue("isPaired");
  my $trimLeft = $self->getParamValue("trimLeft");
  my $trimLeftR = $self->getParamValue("trimLeftR");
  my $truncLen = $self->getParamValue("truncLen");
  my $truncLenR = $self->getParamValue("truncLenR");
  my $readLen = $self->getParamValue("readLen");
  my $taxonRefFile = $self->getParamValue('taxonRefFile');
  my $taskSize = 1;

  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $workflowDataDir = $self->getWorkflowDataDir();
  my $wfName = $self->getWorkflowConfig('name');

  if ($undo) {
    $self->runCmd(0, "rm -rf $workflowDataDir/$taskInputDir/");
  }else {
      #TODO check params here??
      $self->runCmd(0,"mkdir -p $workflowDataDir/$taskInputDir");

      # make controller.prop file
      $self->makeDistribJobControllerPropFile($taskInputDir, 1, $taskSize,
				       "DJob::DistribJobTasks::ASVTableTask", $keepNode); 
      # make task.prop file
      my $taskPropFile = "$workflowDataDir/$taskInputDir/task.prop";
      open(F, ">$taskPropFile") || die "Can't open task prop file '$taskPropFile' for writing";

#TODO probably need to build up paths here, but placeholders for now
      my $taskPropFileContent="

dataDir=$$clusterWorkflowDataDir/$fastqDir
multiplexed=$multiplexed
samplesInfoFile=$clusterWorkflowDataDir/$samplesInfoFile
isPaired=$isPaired
taxonRefFile=$clusterWorkflowDataDir/$taxonRefFile
";

#TODO series of if statements to add other params in as necessary
           
      if (#barcodesType) {
        $taskPropFileContent .= "barcodesType=$barcodesType";
      }
      if (#trimLeft) {
        $taskPropFileContent .= "trimLeft=$trimLeft";
      }
      if (#trimLeftR) {
        $taskPropFileContent .= "trimLeftR=$trimLeftR";
      }
      if (#truncLen) {
        $taskPropFileContent .= "truncLen=$truncLen";
      }
      if (#truncLenR) {
        $taskPropFileContent .= "truncLenR=$truncLenR";
      }
      if (#readLen) {
        $taskPropFileContent .= "readLen=$readLen";
      }

      print F "$taskPropFileContent\n";
       close(F);
  }
}

1;


