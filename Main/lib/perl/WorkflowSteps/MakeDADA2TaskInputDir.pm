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
  my $samplesInfoFileName = $self->getParamValue("samplesInfoFileName");
  my $samplesInfoDir = $self->getParamValue("samplesInfoDir");
  my $isPaired = $self->getParamValue("isPaired");
  my $trimLeft = $self->getParamValue("trimLeft");
  my $trimLeftR = $self->getParamValue("trimLeftR");
  my $truncLen = $self->getParamValue("truncLen");
  my $truncLenR = $self->getParamValue("truncLenR");
  my $maxLen = $self->getParamValue("maxLen");
  my $platform = $self->getParamValue("platform");
  my $fastqsDir = $self->getParamValue("fastqsDir");
  my $sraStudyId = $self->getParamValue("sraStudyId");
  my $sraSampleAndRunIdsFileName = $self->getParamValue("sraSampleAndRunIdsFileName");
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

      if ($samplesInfoFileName){
        if ( -f "$workflowDataDir/$samplesInfoDir/$samplesInfoFileName") {
          $taskPropFileContent .= "samplesInfoFileName=$clusterWorkflowDataDir/$samplesInfoDir/$samplesInfoFileName\n";
        } else {
        die "Samples info file $samplesInfoFileName specified, but not found at $workflowDataDir/$samplesInfoDir/$samplesInfoFileName";
        }
      }
      if ($sraSampleAndRunIdsFileName){
        if ( -f "$workflowDataDir/$samplesInfoDir/$sraSampleAndRunIdsFileName") {
          $taskPropFileContent .= "sraSampleAndRunIdsPath=$clusterWorkflowDataDir/$samplesInfoDir/$sraSampleAndRunIdsFileName\n";
        } else {
        die "sraSampleAndRunIdsFileName file $sraSampleAndRunIdsFileName specified, but not found at $workflowDataDir/$samplesInfoDir/$sraSampleAndRunIdsFileName";
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
      if ($maxLen) {
        $taskPropFileContent .= "maxLen=$maxLen\n";
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


