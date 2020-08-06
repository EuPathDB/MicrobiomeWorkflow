package MicrobiomeWorkflow::Main::WorkflowSteps::MakeDADA2TaskInputDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameter values
  my $propsDir = $self->getParamValue("propsDir");
  my $workingDir = $self->getParamValue("workingDir");
  my $trainingSetPath = $self->getParamValue("trainingSetPath");
  my $speciesAssignmentPath = $self->getParamValue("speciesAssignmentPath");
  my $resultPath = $self->getParamValue("resultPath");
  my $keepNode = $self->getParamValue("keepNode");
  my $samplesInfoFile = $self->getParamValue("samplesInfoFile");
  my $samplesInfoDir = $self->getParamValue("samplesInfoDir");
  my $isPaired = $self->getParamValue("isPaired");
  my $trimLeft = $self->getParamValue("trimLeft");
  my $trimLeftR = $self->getParamValue("trimLeftR");
  my $truncLen = $self->getParamValue("truncLen");
  my $truncLenR = $self->getParamValue("truncLenR");
  my $readLen = $self->getParamValue("readLen");
  my $platform = $self->getParamValue("platform");
  my $fastqsDir = $self->getParamValue("fastqsDir");
  my $sraStudyId = $self->getParamValue("sraStudyId");
  my $mergeTechReps = $self->getBooleanParamValue("mergeTechReps");
  my $taskSize = 1;

  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $workflowDataDir = $self->getWorkflowDataDir();
  my $wfName = $self->getWorkflowConfig("name");

  if ($undo) {
    $self->runCmd(0, "rm -rf $workflowDataDir/$propsDir/");
  }else {
      #TODO check params here??
      $self->runCmd(0,"mkdir -p $workflowDataDir/$propsDir");

      # make controller.prop file
      $self->makeDistribJobControllerPropFile($propsDir, 1, $taskSize,
				       "DJob::DistribJobTasks::ASVTableTask", $keepNode); 

#TODO probably need to build up paths here, but placeholders for now
      my $taskPropFileContent="
workingDir=$clusterWorkflowDataDir/$workingDir
trainingSetFile=$clusterWorkflowDataDir/$trainingSetPath
speciesAssignmentFile=$clusterWorkflowDataDir/$speciesAssignmentPath
resultFile=$clusterWorkflowDataDir/$resultPath
";

      if ($samplesInfoFile){
        if ( -f "$workflowDataDir/$samplesInfoDir/$samplesInfoFile") {
          $taskPropFileContent .= "samplesInfoFile=$clusterWorkflowDataDir/$samplesInfoDir/$samplesInfoFile\n";
        } else {
        die "Samples info file $samplesInfoFile specified, but not found at $workflowDataDir/$samplesInfoDir/$samplesInfoFile";
        }
      }
      if ( glob("$workflowDataDir/$fastqsDir/*") ){
        $taskPropFileContent .= "dataDir=$clusterWorkflowDataDir/$fastqsDir\n";
      } elsif ($sraStudyId) {
        $taskPropFileContent .= "sraStudyId=$sraStudyId\n";
      } else {
        die "Fastqs from manual delivery not at $workflowDataDir/$fastqsDir, and no sraStudyId specified";
      }

      if ($mergeTechReps) {
        $taskPropFileContent .= "mergeTechReps=true\n";
      } else {
        $taskPropFileContent .= "mergeTechReps=false\n";
      } 
      if ($isPaired) {
        $taskPropFileContent .= "isPaired=$isPaired\n";        
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
      if ($platform) {
        $taskPropFileContent .= "platform=$platform\n";
      }

      # make task.prop file
      my $taskPropFile = "$workflowDataDir/$propsDir/task.prop";
      open(F, ">$taskPropFile") or die "$!: can't open task prop file '$taskPropFile' for writing";

      print F "$taskPropFileContent\n";
       close(F);
  }
}

1;


