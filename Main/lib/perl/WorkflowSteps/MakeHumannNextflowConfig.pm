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

### reasons for settings, by Wojtek
# ref dbs in home dir: the tools are installed to my home dir too
# retrying downloads: really useful when downloading from the public ENA FTP
# kneaddata memory - it runs bowtie2 against hg37, which I saw to take 3.2GB peak
# humann memory - it runs diamond which promises to take about six times --block-size in GB
    print F
"params {
  sampleToFastqsPath = '$clusterSampleToFastqPath' 
  resultDir = '$clusterResultDir'
  kneaddataCommand = \"kneaddata --trimmomatic ~/lib/Trimmomatic-0.39 --max-memory 3000m --bypass-trf --reference-db ~/kneaddata_databases\"
  wgetCommand = \"wget --waitretry=10 --read-timeout=20 --retry-connrefused --tries 3\"
  humannCommand = \"humann --diamond-options \\\" --block-size 0.8 --top 1 --outfmt 6\\\"\"
  functionalUnits = [\"level4ec\"]
}

process {
  executor = '$executor'
  queue = '$queue'
  maxForks = 40
  withLabel: 'download_and_preprocess' {
    errorStrategy {
      if (task.exitStatus == 8 || task.attempt < 4 ) {
        return 'retry'
      } else {
        return 'finish'
      }
    }
    maxRetries = 10
    maxForks = 5
    clusterOptions = '-M 4000 -R \"rusage [mem=4000] span[hosts=1]\"'
  }
  withName: 'runHumann' {
    clusterOptions = '-M 8000 -R \"rusage [mem=8000] span[hosts=1]\"'
    errorStrategy = 'finish'
  }
}
";

  close(F);
 }
}

1;

