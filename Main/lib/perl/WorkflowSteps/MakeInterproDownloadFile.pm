package OrthoMCLWorkflow::Main::WorkflowSteps::MakeInterproDownloadFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $interproExtDb = $self->getParamValue('interproExtDbName');
  my $downloadSiteDir = $self->getParamValue('downloadSiteDir');
  my $release = $self->getParamValue('release');
  my $project = $self->getParamValue('project');

  my $interproExtDbVer = $self->getExtDbVersion($test,$interproExtDb);

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);

  my $downloadFileName = "$websiteFilesDir/$downloadSiteDir/iprscan_$project-$release.txt";

  my $sql = <<"EOF";
     SELECT xas.secondary_identifier
           || chr(9) ||
         xd.name
           || chr(9) ||
         dr.primary_identifier
           || chr(9) ||
         dr.secondary_identifier
           || chr(9) ||
         al.start_min
           || chr(9) ||
         al.end_min
           || chr(9) ||
         to_char(df.e_value,'9.9EEEE')
  FROM
    dots.aalocation al,
    sres.externaldatabaserelease xdr,
    sres.externaldatabase xd,
    sres.dbref dr,
    dots.DbRefAAFeature draf,
    dots.domainfeature df,
    dots.externalaasequence xas
  WHERE
     xas.aa_sequence_id = df.aa_sequence_id
     AND df.aa_feature_id = al.aa_feature_id
     AND df.aa_feature_id = draf.aa_feature_id
     AND draf.db_ref_id = dr.db_ref_id
     AND df.external_database_release_id = xdr.external_database_release_id
     AND xdr.external_database_id = xd.external_database_id
     AND xdr.version = '$interproExtDbVer'
     AND xd.name = '$interproExtDb'
EOF

  if ($undo) {
    $self->runCmd($test, "rm $downloadFileName");
  } else {
    $self->runCmd($test, "makeFileWithSql --outFile $downloadFileName --sql \"$sql\"");
  }
}


