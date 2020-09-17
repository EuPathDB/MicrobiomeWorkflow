package MicrobiomeWorkflow::Main::RetrieveHumannResultsFromComputeCluster;

@ISA = (ReFlow::Controller::WorkflowStepHandle);

use strict;
use warnings;
use ReFlow::Controller::WorkflowStepHandle;
use File::Basename;

sub run {
  my ($self, $test, $undo) = @_;

  my $clusterDir = join("/", $self->getClusterWorkflowDataDir(), $self->getParamValue("clusterDir"));
  my $targetDir = join("/", $self->getWorkflowDataDir(), $self->getParamValue("targetDir"));

  my $otuCountsFileName = $self->getParamValue("otuCountsFileName");
  my $pathwayAbundancesFileName = $self->getParamValue("pathwayAbundancesFileName");
  my $pathwayCoveragesFileName = $self->getParamValue("pathwayCoveragesFileName");
  my $level4ECsFileName = $self->getParamValue("level4ECsFileName");

  if($undo){
    for my $fileName ($otuCountsFileName, $pathwayAbundancesFileName, $pathwayCoveragesFileName, $level4ECsFileName){
      $self->runCmd(0, "rm -f $targetDir/$fileName");
    }
  }else {
    if ($test) {
      for my $fileName ($otuCountsFileName, $pathwayAbundancesFileName, $pathwayCoveragesFileName, $level4ECsFileName){
        $self->runCmd(0, "echo test > $targetDir/$fileName");
      }
    } else {
      my $tmp = "$targetDir/tmp." . int(rand(10000));
      $self->runCmd(0, "mkdir $tmp");
      for my $p (
        ["taxon_abundances.tsv", $otuCountsFileName],
        ["level4ecs.tsv", $level4ECsFileName],
        ["pathway_abundances.tsv", $pathwayAbundancesFileName],
        ["pathway_coverages.tsv", $pathwayCoveragesFileName]){
        my ($from, $to) = @$p;
        $self->copyFromCluster("$clusterDir", $from, $tmp, 0);
        $self->runCmd(0, "mv $tmp/$from $targetDir/$to");
      }

      $self->runCmd(0, "rmdir $tmp");
    }
  }

}

sub getParamDeclaration {
  return (
	"clusterDir",
	"targetDir",
	"otuCountsFileName",
	"pathwayAbundancesFileName",
	"pathwayCoveragesFileName",
	"level4ECsFileName",
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}
1;
