package MicrobiomeWorkflow::Main::RetrieveFunscanResultsFromComputeCluster;

@ISA = (ReFlow::Controller::WorkflowStepHandle);

use strict;
use warnings;
use ReFlow::Controller::WorkflowStepHandle;
use File::Basename;

sub run {
  my ($self, $test, $undo) = @_;

  my $clusterDir = join("/", $self->getClusterWorkflowDataDir(), $self->getParamValue("clusterDir"));
  my $targetDir = join("/", $self->getWorkflowDataDir(), $self->getParamValue("targetDir"));

  if($undo){
    $self->runCmd(0, "rm -f $targetDir/*");
  }else {
    if ($test) {
      $self->runCmd(0, "echo test > $targetDir/test.txt"); ## TODO a real file name or something here
    } else {
      
      ## TODO decide what all we need from funcscan and collect it up nicely here
      ## $self->runCmd(0, "fun stuff here");
      my $from = "TODO";
      my $to = "TODO";

      $self->copyFromCluster("$clusterDir", $from, $to, 0);
    }
  }

}

sub getParamDeclaration {
  return (
	"clusterDir",
	"targetDir",
	);
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	);
}
1;
