package MicrobiomeWorkflow::Main::RetrieveEukdetectResultsFromComputeCluster;

@ISA = (ReFlow::Controller::WorkflowStepHandle);

use strict;
use warnings;
use ReFlow::Controller::WorkflowStepHandle;
use File::Basename;

sub run {
  my ($self, $test, $undo) = @_;

  my $clusterDir = join("/", $self->getClusterWorkflowDataDir(), $self->getParamValue("clusterDir"));
  my $targetDir = join("/", $self->getWorkflowDataDir(), $self->getParamValue("targetDir"));

  my $cpmsTargetFileName = $self->getParamValue("cpmsTargetFileName");

  if($undo){
    $self->runCmd(0, "rm -f $targetDir/$cpmsTargetFileName");
  }else {
    if ($test) {
      $self->runCmd(0, "echo test > $targetDir/$cpmsTargetFileName");
    } else {
      my $tmp = "$targetDir/tmp." . int(rand(10000));

      $self->runCmd(0, "mkdir $tmp");
      #my $from = "cpms.tsv";
      my $from = "cpm.matrix.tsv";
      $self->copyFromCluster("$clusterDir", $from, $tmp, 0);
      $self->runCmd(0, "mv $tmp/$from $targetDir/$cpmsTargetFileName");

      $self->runCmd(0, "rmdir $tmp");
    }
  }

}

sub getParamDeclaration {
  return (
	"clusterDir",
	"targetDir",
	"cpmsTargetFileName",
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}
1;
