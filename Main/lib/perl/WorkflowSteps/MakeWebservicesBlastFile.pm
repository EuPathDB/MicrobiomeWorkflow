 package OrthoMCLWorkflow::Main::WorkflowSteps::MakeWebservicesBlastFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

 sub run {
   my ($self, $test, $undo) = @_;

   my $websiteFilesDir = $self->getWebsiteFilesDir($test);

   my $webServicesDir = $self->getParamValue('webServicesDir');

   my $webSvcDir = "$websiteFilesDir/$webServicesDir";

   my $downloadsDir = $self->getParamValue('downloadSiteDir');
  
   my $release = $self->getParamValue('release');
   my $project = $self->getParamValue('project');


   my $ncbiBlastPath = $self->getConfig('ncbiBlastPath');

   my $workflowDataDir = $self->getWorkflowDataDir();

   my $seqsDownloadFileName = "$websiteFilesDir/$downloadsDir/aa_seqs_$project-$release.fasta.gz";


   if ($undo) {
     $self->runCmd(0, "rm -rf $webSvcDir/blast");
   } else {
     $self->runCmd($test,"mkdir $webSvcDir/blast");
     $self->runCmd($test,"cp $seqsDownloadFileName $webSvcDir/blast/proteinSeqs.gz");
     $self->runCmd($test,"gunzip $webSvcDir/blast/proteinSeqs.gz");
     $self->runCmd($test,"$ncbiBlastPath/makeblastdb  -in $webSvcDir/blast/proteinSeqs -dbtype prot");
     $self->runCmd($test,"grep \> $webSvcDir/blast/proteinSeqs | wc > $webSvcDir/blast/proteinSeqs.count");
     $self->runCmd($test,"rm $webSvcDir/blast/proteinSeqs");
   }
 }


