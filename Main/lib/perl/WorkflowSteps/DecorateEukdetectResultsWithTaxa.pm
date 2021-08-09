package MicrobiomeWorkflow::Main::WorkflowSteps::DecorateEukdetectResultsWithTaxa;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $inputPath =  $self->getParamValue("inputPath");
  my $outputPath =  $self->getParamValue("outputPath");

  if($undo){
    return;
  }
  if($test){
    die "No file at $inputPath" unless -f $inputPath;
    `touch $outputPath`;
    return;
  }

  my @lines;

  open(my $fh, "<", $inputPath) or die "$!: $inputPath";
  my ($idH, $valuesH) = split("\t", <$fh>, 2);
  push @lines, "lineage\t$valuesH";
  while(my ($id, $values) = split ("\t", <$fh>, 2){
    my ($ncbiTaxonId, $label) = split ("|", $id);
    die "No taxon id field in $id line $." unless $ncbiTaxonId;
    my @lineage = $self->getMbioLineageForTaxonId($ncbiTaxonId);
    die "No lineage found for taxon $ncbiTaxonId" unless @lineage;
    push @lines, join(";", @lineage) . "\t" . $values;
  }

  open(my $outfh, ">", $outputPath) or die "$!: $outputPath";
  for my $line (@lines){
    print $outfh $line;
  }
}

my @levels = ('kingdom', 'phylum', 'class', 'order', 'family', 'genus', 'species');
my $levelsString = "'kingdom', 'phylum', 'class', 'order', 'family', 'genus', 'species'";
sub getMbioLineageForTaxonId {
  my ($self, $ncbiTaxonId) = @_;
  my $sql = "
  select rank, name from (
  select taxon_id, ncbi_tax_id, rank from sres.taxon
           connect by taxon_id = prior parent_id
           start with ncbi_tax_id = $ncbiTaxonId
  ) t, sres.taxonname tn
  where t.taxon_id = tn.taxon_id
  and name_class = 'scientific name'
  and rank in ($levelsString);
";

  my %result;
  my $stmt = $self->getWorkflow()->_runSql($sql);
  while (my ($rank, $name) = $stmt->fetchrow_array()) {
    $result{$rank} = $name;
  }
  return unless %result;
  return map {$_ // ""} @result{@levels};
}
