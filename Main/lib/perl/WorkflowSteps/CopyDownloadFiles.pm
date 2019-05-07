package MicrobiomeWorkflow::Main::WorkflowSteps::CopyDownloadFiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

use File::Basename;
use Digest::SHA qw(sha1_hex);

sub run {
  my ($self, $test, $undo) = @_;

  my $inputFileBaseName = $self->getParamValue('inputFileBaseName');
  my $downloadDir = $self->getParamValue('relativeDownloadSiteDir');

  # standard parameters for making download files
  my $websiteFilesDir = $self->getWebsiteFilesDir($test);
  my $workflowDataDir = $self->getWorkflowDataDir() . "/downloadSiteFiles";

  opendir my $dir, $workflowDataDir or die "Cannot open directory: $workflowDataDir";
  my @files = readdir $dir;
  closedir $dir;

  if ($undo) {
    $self->runCmd(0, "rm -f $websiteFilesDir/$downloadDir/*");
  } else {
    for my $datasetName (@files) {
      next if ($datasetName eq '.' || $datasetName eq '..');
      $datasetName =~ s/($inputFileBaseName)_//g;
      my $outFile = $datasetName;
      $datasetName =~ s/\.txt//;
      my $copyToDownloadDir = "$websiteFilesDir/$downloadDir/$datasetName";

      $self->runCmd($test, "mkdir -p $copyToDownloadDir");
      $self->runCmd($test, "cp $workflowDataDir/${inputFileBaseName}_$outFile $copyToDownloadDir/$outFile");
    }
  }
}
1;
