package MicrobiomeWorkflow::Main::WorkflowSteps::MakeNfCorePMACSConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $configPath = join("/", $self->getWorkflowDataDir(),  $self->getParamValue("analysisDir"), $self->getParamValue("configFileName"));

  my $memoryInGb = $self->getParamValue("memoryInGb");
  my $nextflowTowerAccessToken = $self->getParamValue("nextflowTowerAccessToken");
  my $nextflowTowerWorkspaceId = $self->getParamValue("nextflowTowerWorkspaceId");

  # not sure we need to grab these, since this is pmacs specific :(
  # id like to look into a pmacs config file here: https://nf-co.re/configs
  my $executor = $self->getClusterExecutor();
  my $queue = $self->getClusterQueue();

  if ($undo) {
    $self->runCmd(0,"rm -rf $configPath");
  } else {
    open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";

    print F
"process {
  executor = '$executor'
  queue = '$queue'
}
// nf-core requests memory in kb
// pmacs wants requests for memory in mb
// therefore, request for 6mb will look like 6gb to pmacs.
// having to do this trick makes this config specific to pmacs, unfortunately.
params {
  max_memory = $memoryInGb.MB
}
singularity {
  enabled = true
}
tower {
  accessToken = '$nextflowTowerAccessToken'
  workspaceId = '$nextflowTowerWorkspaceId'
  enabled = true
}";
  close(F);
  }
}

1;

