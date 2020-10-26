package MicrobiomeWorkflow::Main::WorkflowSteps::MakeHumannNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $configPath = join("/", $self->getWorkflowDataDir(),  $self->getParamValue("analysisDir"), $self->getParamValue("configFileName"));
  my $sampleToFastqPath = join("/", $self->getWorkflowDataDir(), $self->getParamValue("analysisDir"), $self->getParamValue("sampleToFastqFileName"));

  my $clusterSampleToFastqPath = join("/", $self->getClusterWorkflowDataDir(), $self->getParamValue("analysisDir"), $self->getParamValue("sampleToFastqFileName"));
  my $clusterResultDir = join("/", $self->getClusterWorkflowDataDir(), $self->getParamValue("clusterResultDir"));

  my $executor = $self->getClusterExecutor();
  my $queue = $self->getClusterQueue();

  if ($undo) {
    $self->runCmd(0,"rm -rf $configPath");
  } else {
    $self->testInputFile('sampleToFastqPath', $sampleToFastqPath);

    open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";

    print F
"params {
  sampleToFastqsPath = '$clusterSampleToFastqPath' 
  resultDir = '$clusterResultDir'
  kneaddataCommand = \"kneaddata --trimmomatic ~/lib/Trimmomatic-0.39 --bypass-trf --reference-db ~/kneaddata_databases\"
  wgetCommand = \"wget --waitretry=10 --read-timeout=20 --retry-connrefused --tries 3\"
  functionalUnits = [\"level4ec\"]
}

process {
  executor = '$executor'
  queue = '$queue'
  maxForks = 20
  withLabel: 'mem_4c' {
    errorStrategy = { task.exitStatus in 130..140 ? 'retry' : 'terminate' }
    maxRetries = 3
    clusterOptions = { task.attempt == 1 ?
      '-n 4 -M 12000 -R \"rusage [mem=12000] span[hosts=1]\"'
      : task.attempt == 2 ?
      '-n 4 -M 17000 -R \"rusage [mem=17000] span[hosts=1]\"'
      : '-n 4 -M 25000 -R \"rusage [mem=25000] span[hosts=1]\"'
    }
  }
}
";

  close(F);
 }
}

1;

