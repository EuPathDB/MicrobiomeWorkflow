package MicrobiomeWorkflow::Main::WorkflowSteps::CopyDownloadFiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

use File::Basename;
use Digest::SHA qw(sha1_hex);

sub run {
  my ($self, $test, $undo) = @_;

  my $sourceDir = join("/", $self->getWorkflowDataDir() , $self->getParamValue('sourceDir'));
  my $allDatasetsPath = join("/", $sourceDir, $self->getParamValue('allDatasetsFileName'));

  my @datasets;
  open(my $fh, "<", $allDatasetsPath) or die "$!: $allDatasetsPath";
  while(<$fh>){
     chomp;
     s{otuDADA2_(.*)_RSRC}{$1};
     push @datasets, $_;
  }
  die "No datasets in $allDatasetsPath" unless @datasets;

  my $targetDir = join("/", $self->getWebsiteFilesDir($test), $self->getParamValue('targetDir'));

  if ($undo) {
    $self->runCmd(0, "rm -fr $targetDir/*");
  } else {
    $self->runCmd($test, "printf \"IndexIgnore *\" > $targetDir/.htaccess");

    for my $dataset (@datasets) {
      my $datasetTargetDir = join("/", $targetDir, sha1_hex("otuDADA2_${dataset}_RSRC"));

      $self->runCmd($test, "mkdir -pv $datasetTargetDir");
      $self->runCmd($test, "printf \"IndexIgnoreReset ON\nIndexIgnore ..\" > $datasetTargetDir/.htaccess");
      $self->runCmd($test, "cp -v $sourceDir/${dataset}* $datasetTargetDir/");
    }
  }
}
1;
