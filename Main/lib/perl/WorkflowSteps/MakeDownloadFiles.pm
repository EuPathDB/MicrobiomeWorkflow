package MicrobiomeWorkflow::Main::WorkflowSteps::MakeDownloadFiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonData::Load::MBioResultsTable;


use GUS::ObjRelP::DbiDatabase;
use DBI;
sub run {
  my ($self, $test, $undo) = @_;

  
  my $ampliconTaxaSuffix = $self->getParamValue('ampliconTaxaSuffix');
  my $wgsTaxaSuffix = $self->getParamValue('wgsTaxaSuffix');
  my $level4ECsSuffix = $self->getParamValue('level4ECsSuffix');
  my $pathwayAbundancesSuffix = $self->getParamValue('pathwayAbundancesSuffix');
  my $pathwayCoveragesSuffix = $self->getParamValue('pathwayCoveragesSuffix');

  my $outputDir = join("/", $self->getWorkflowDataDir() , $self->getParamValue('outputDir'));

  my $allResultsDir = join("/", $self->getWorkflowDataDir(), $self->getParamValue('allResultsDir'));

  my $outFileDatasets = join("/", $outputDir, $self->getParamValue('allDatasetsFileName'));
  my $outFileSampleDetails = join("/", $outputDir, "all_sample_details.tsv");

  if ($undo) {
    $self->runCmd(0, "rm -f $outFileDatasets");
    $self->runCmd(0, "rm -f $outFileSampleDetails");
  } else {
    if ($test) {
      $self->runCmd(0,"echo test > $outFileDatasets");
      $self->runCmd(0,"echo test > $outFileSampleDetails");
      return;
    }
    my $datasets = $self->writeDatasetsAndReadThemBack($test, $outFileDatasets); 
    my $sampleDetailsByDataset = $self->writeSampleDetailsAndReadThemBack($test, $outFileSampleDetails); 
    for my $dataset (@{$datasets}){
      my $ampliconTaxaPath = "$allResultsDir/${dataset}${ampliconTaxaSuffix}";
      my $wgsTaxaPath = "$allResultsDir/${dataset}${wgsTaxaSuffix}";
      my $level4ECsPath = "$allResultsDir/${dataset}${level4ECsSuffix}";
      my $pathwayAbundancesPath = "$allResultsDir/${dataset}${pathwayAbundancesSuffix}";
      my $pathwayCoveragesPath = "$allResultsDir/${dataset}${pathwayCoveragesSuffix}";
      my ($ampliconTaxaTable, $wgsTaxaTable, $level4ECsTable, $pathwaysTable);
      if (-f $ampliconTaxaPath){
        $ampliconTaxaTable = ApiCommonData::Load::MBioResultsTable->ampliconTaxa($ampliconTaxaPath);
        $ampliconTaxaTable->addSampleDetails($sampleDetailsByDataset->{$dataset});
        $ampliconTaxaTable->writeTabSampleDetails("$outputDir/$dataset.16s_DADA2.sample_details.tsv");
        $ampliconTaxaTable->writeBiom("$outputDir/$dataset.16s_DADA2.taxon_abundance.biom");
        $ampliconTaxaTable->writeTabData("$outputDir/$dataset.16s_DADA2.taxon_abundance.tsv");
      }
      if (-f $wgsTaxaPath){
        $wgsTaxaTable = ApiCommonData::Load::MBioResultsTable->wgsTaxa($wgsTaxaPath);
        $level4ECsTable = ApiCommonData::Load::MBioResultsTable->wgsFunctions("level4EC", $level4ECsPath);
        $pathwaysTable = ApiCommonData::Load::MBioResultsTable->wgsPathways($pathwayAbundancesPath, $pathwayCoveragesPath);

        $wgsTaxaTable->addSampleDetails($sampleDetailsByDataset->{$dataset});
        $level4ECsTable->addSampleDetails($sampleDetailsByDataset->{$dataset});
        $pathwaysTable->addSampleDetails($sampleDetailsByDataset->{$dataset});
        $wgsTaxaTable->writeTabSampleDetails("$outputDir/$dataset.WGS.sample_details.tsv");
        $wgsTaxaTable->writeBiom("$outputDir/$dataset.WGS.taxon_abundance.biom");
        $level4ECsTable->writeBiom("$outputDir/$dataset.WGS.level4ECs.biom");
        $pathwaysTable->writeBiom("$outputDir/$dataset.WGS.pathways.biom");
        $wgsTaxaTable->writeTabData("$outputDir/$dataset.WGS.taxon_abundance.tsv");
        $level4ECsTable->writeTabData("$outputDir/$dataset.WGS.level4ECs.tsv");
        $pathwaysTable->writeTabData("$outputDir/$dataset.WGS.pathways.tsv");

      }
      if (! -f $ampliconTaxaPath && ! -f $wgsTaxaPath){
        die "Error: no files for $dataset (neither $ampliconTaxaPath nor $ampliconTaxaPath )";
      } 
    }
  }
}

sub writeDatasetsAndReadThemBack {
  my ($self, $test, $outFileDatasets) = @_;
  my $sqlDatasets = "select distinct DATASET_NAME from apidbtuning.panextdbrls where DATASET_NAME != 'ISASimple_RSRC'";
  $self->runCmd($test,"makeFileWithSql --outFile $outFileDatasets --sql \"$sqlDatasets\" --verbose --outDelimiter '\\t'");

  my @result;
  open(my $fh, "<", $outFileDatasets) or die "$!:$outFileDatasets";
  while(<$fh>){
   chomp;
   s{otuDADA2_(.*)_RSRC}{$1};
   push @result, $_;
  }
  return \@result;
}

sub writeSampleDetailsAndReadThemBack {
  my ($self, $test, $outFileSampleDetails) = @_;
  my $sqlSampleDetails = <<"EOF";
select m.dataset_name
      , m.pan_name as sample_id
      , o.ontology_term_name as property_name
      , m.string_value as property_value
from apidbtuning.Ontology o
left join apidbtuning.Metadata m
on o.ontology_term_source_id = m.property_source_id
where o.ontology_term_source_id is not null
EOF
  
  $self->runCmd($test,"makeFileWithSql --outFile $outFileSampleDetails --sql \"$sqlSampleDetails\" --verbose --outDelimiter '\\t'");
  my %result;
  open(my $fh, "<", $outFileSampleDetails) or die "$!:$outFileSampleDetails";
  while(<$fh>){
    chomp;
    my ($datasetName, $sampleId, $propertyName, $propertyValue) = split "\t";
    $datasetName =~ s{otuDADA2_(.*)_RSRC}{$1};
    $sampleId =~ s{ .*$}{};

    $result{$datasetName}{$sampleId}{$propertyName} = $propertyValue;
  }
  return \%result;
}
1;
