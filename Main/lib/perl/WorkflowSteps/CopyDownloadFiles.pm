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
    $self->runCmd(0, "rm -fr $websiteFilesDir/$downloadDir/*");
  } else {

    $self->runCmd($test, "printf \"IndexIgnore *\" > $websiteFilesDir/$downloadDir/.htaccess");

    for my $datasetName (@files) {
      next if ($datasetName eq '.' || $datasetName eq '..');
      $datasetName =~ s/($inputFileBaseName)_//g;
      my $outFile = $datasetName;
      $datasetName =~ s/\.txt//;
      next if ($datasetName eq 'ontologyMetadata');
      my $digest = sha1_hex($datasetName);
      my $copyToDownloadDir = "$websiteFilesDir/$downloadDir/$digest";

      $self->runCmd($test, "mkdir -p $copyToDownloadDir");
      $self->runCmd($test, "printf \"IndexIgnoreReset ON\nIndexIgnore ..\" > $copyToDownloadDir/.htaccess");
      $self->runCmd($test, "cp $workflowDataDir/${inputFileBaseName}_ontologyMetadata.txt $copyToDownloadDir/ontologyMetadata.txt");
      $self->runCmd($test, "cp $workflowDataDir/${inputFileBaseName}_$outFile $copyToDownloadDir/$outFile");
    }
  }
}
1;
