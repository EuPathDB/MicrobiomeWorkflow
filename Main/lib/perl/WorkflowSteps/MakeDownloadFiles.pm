package MicrobiomeWorkflow::Main::WorkflowSteps::MakeDownloadFiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $outputFileBaseName = $self->getParamValue('outputFileBaseName');

  my $sql = "
select * from apidbtuning.taxonrelativeabundance ra,
apidbtuning.samples s,
apidbtuning.panextdbrls pedb
where ra.name = s.name
and ra.protocol_app_node_id = pedb.pan_id
and pedb.dataset_name != 'ISASimple_RSRC'
";

  my $ontologyMetadataSql = "
select distinct o.ontology_term_source_id as iri
      , o.ontology_term_name as label
      , o.type as type
      , o.parent_ontology_term_name as parentLabel
      , m.category as category
      , o.description as definition
from apidbtuning.Ontology o 
left join apidbtuning.Metadata m 
on o.ontology_term_source_id = m.property_source_id 
where o.ontology_term_source_id is not null
";

  #TODO owl reader, like done for clinepi

  my $workflowDataDir = $self->getWorkflowDataDir() . "/downloadSiteFiles";
  my $outFile = "$workflowDataDir/${outputFileBaseName}_masterDataTable.txt";
  my $ontologyFile = "$workflowDataDir/ontologyMetadata.txt";

  if ($undo) {
      $self->runCmd(0, "rm -f $outFile");
      $self->runCmd(0, "rm -f $ontologyFile");
  } else {
      if ($test) {
	    $self->runCmd(0,"echo test > $outFile");
      }
      $self->runCmd($test,"makeFileWithSql --outFile $outFile --sql \"$sql\" --verbose --includeHeader --outDelimiter '\\t'");
      $self->runCmd($test,"makeFileWithSql --outFile $ontologyFile --sql \"$ontologyMetadataSql\" --verbose --includeHeader --outDelimiter '\\t'");

      my $cmd = "Rscript $ENV{GUS_HOME}/bin/splitMbioDownloadSiteFiles.R $workflowDataDir $outputFileBaseName"; 
      $self->runCmd($test, $cmd);
  }
}

1;
