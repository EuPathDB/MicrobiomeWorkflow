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
  kneaddataCommand = \"kneaddata --trimmomatic /usr/share/java --max-memory 3000m --bypass-trf --reference-db /kneaddata_databases\"
  wgetCommand = \"wget --waitretry=10 --read-timeout=20 --retry-connrefused --tries 3\"
  humannCommand = \"humann --diamond-options \\\" --block-size 1.0 --top 1 --outfmt 6\\\"\"
  functionalUnits = [\"level4ec\"]
}

process {
  container = 'docker://veupathdb/humann'
  executor = '$executor'
  queue = '$queue'
  maxForks = 40
  withLabel: 'download_and_preprocess' {
    errorStrategy = {
      sleep(Math.pow(2, task.attempt) * 500 as long);
      if (task.exitStatus == 8 || task.exitStatus == 4 || task.attempt < 4 ) {
        return 'retry'
      } else {
        return 'finish'
      }
    }
    maxRetries = 10
    maxForks = 5
    clusterOptions = {
      (task.attempt > 1 && task.exitStatus in 130..140)
        ? '-M 12000 -R \"rusage [mem=12000] span[hosts=1]\"'
        : '-M 4000 -R \"rusage [mem=4000] span[hosts=1]\"'
    }
  }
  withName: 'runHumann' {
    errorStrategy = { task.exitStatus in 130..140 ? 'retry' : 'finish' }
    maxRetries = 2
    clusterOptions = { task.attempt == 1 ?
      '-M 12000 -R \"rusage [mem=12000] span[hosts=1]\"'
      : '-M 18000 -R \"rusage [mem=18000] span[hosts=1]\"'
    }
  }
}

 singularity {
     enabled = true
     runOptions = \"--bind ~/humann_databases:/humann_databases --bind ~/kneaddata_databases:/kneaddata_databases --bind /project:/project\"
 }
";
  close(F);
 }
}

1;

