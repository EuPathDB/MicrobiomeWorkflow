package MicrobiomeWorkflow::Main::WorkflowSteps::MakeSnakemakeInputDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

#example to make completely custom snakemake workflow

sub run {
  my ($self, $test, $undo) = @_;

  # get parameter values
  my $taskInputDir = $self->getParamValue("taskInputDir");
  my $extDBName = $self->getParamValue("extDBName");

  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $workflowDataDir = $self->getWorkflowDataDir();
  my $wfName = $self->getWorkflowConfig('name');

  if ($undo) {
    $self->runCmd(0, "rm -rf $workflowDataDir/$taskInputDir/");
  } else {
      $self->runCmd(0,"mkdir -p $workflowDataDir/$taskInputDir");
      #move any inputs received from manualDelivery to where snakemake will find them
      $self->runCmd(0,"cp $workflowDataDir/$extDBName/final/* $workflowDataDir/$taskInputDir");

      #TODO copy custom snakefile to inputDir/snakefile, but dont pass snakefile to RunAndMonitorSnakemake

      # make task.prop file and reference in your custom snakefile
      #my $taskPropFile = "$workflowDataDir/$taskInputDir/config.yaml";
      #open(F, ">$taskPropFile") || die "Can't open task prop file '$taskPropFile' for writing";

      #TODO decide what if anything we want here
      #my $taskPropFileContent="";

      #print F "$taskPropFileContent\n";
      # close(F);
  }
}

1;


