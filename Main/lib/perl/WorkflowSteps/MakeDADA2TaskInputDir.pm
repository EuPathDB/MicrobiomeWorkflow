package MicrobiomeWorkflow::Main::WorkflowSteps::MakeDADA2TaskInputDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

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

dataDir=$clusterWorkflowDataDir/$fastqDir
taxonRefFile=$clusterWorkflowDataDir/$taxonRefFile
";

      my $testSamplesInfoFile = "$workflowDataDir/$samplesInfoFile";
      if ( -f $testSamplesInfoFile) {
        $taskPropFileContent .= "samplesInfoFile=$clusterWorkflowDataDir/$samplesInfoFile\n";
      } else {
        warn "No samplesInfoFile found..";
      }

      if ($multiplexed) {
        $taskPropFileContent .= "multiplexed=true\n";
      } else {
        $taskPropFileContent .= "multiplexed=false\n";
      }          
      if ($isPaired) {
        $taskPropFileContent .= "isPaired=true\n";        
      } else {          
        $taskPropFileContent .= "isPaired=false\n";
      } 

      if ($barcodesType) {
        $taskPropFileContent .= "barcodesType=$barcodesType\n";
      }
      if ($trimLeft) {
        $taskPropFileContent .= "trimLeft=$trimLeft\n";
      }
      if ($trimLeftR) {
        $taskPropFileContent .= "trimLeftR=$trimLeftR\n";
      }
      if ($truncLen) {
        $taskPropFileContent .= "truncLen=$truncLen\n";
      }
      if ($truncLenR) {
        $taskPropFileContent .= "truncLenR=$truncLenR\n";
      }
      if ($readLen) {
        $taskPropFileContent .= "readLen=$readLen\n";
      }

      print F "$taskPropFileContent\n";
       close(F);
  }
}

1;


