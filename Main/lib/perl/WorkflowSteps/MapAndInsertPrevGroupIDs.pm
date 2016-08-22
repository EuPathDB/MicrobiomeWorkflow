package OrthoMCLWorkflow::Main::WorkflowSteps::MapAndInsertPrevGroupIDs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

# Use the FASTA files for a single proteome from all previous releases to map
# old seq IDs to new ones.
#
# Iterate through a directory structure containing previous release FASTA files.  The dir
# structure contains one subdir per release, each of which contain old proteome fasta files,
# named in the form oldabbrev.fasta.gz
#
# In each of the release dirs, see if our proteome is present.  It might be there using
# on old abbreviation (see oldAbbrevsList) or the current abbrev for that proteome.
#
# If our proteome is present in an old release call a plugin to read that old fasta file and
# insert the mapping


sub run {
  my ($self, $test, $undo) = @_;

  my $inputDir = $self->getParamValue('inputDir'); # contains one subdir per release, each of which contain old proteome fasta files
  my $abbrev = $self->getParamValue('abbrev');
  my $oldAbbrevsList = $self->getParamValue('oldAbbrevsList'); # example:  "2:pfa, 3:pfa"  only specify those that differ from abbrev

  my $oldAbbrevs = $self->parseOldAbbrevsList($oldAbbrevsList, $abbrev);

  my $workflowDataDir = $self->getWorkflowDataDir();

  $self->testInputFile('inputDir', "$workflowDataDir/$inputDir");

  opendir(DIR, "$workflowDataDir/$inputDir") || die "Can't open directory '$workflowDataDir/$inputDir'";

  while (my $groupFile = readdir (DIR)) {
    next if ($groupFile eq "." || $groupFile eq "..");

    $groupFile =~ /groups_OrthoMCL-(\d+)\.txt/ || die "invalid groupFile format $groupFile\n";
    my $release = $1;

    my $oldAbbrev = $abbrev;
    $oldAbbrev = $oldAbbrevs->{$release} if ($oldAbbrevs->{$release});

    unlink("tmpTaxonMap") if -e "tmpTaxonMap";
    open(F, ">tmpTaxonMap");
    print F "$oldAbbrev $abbrev\n";
    close(F);

    my $args = "--oldGroupsFile $workflowDataDir/$inputDir/$groupFile --taxonMapFile tmpTaxonMap --dbVersion $release";

    $self->runPlugin($test, $undo, "OrthoMCLData::Load::Plugin::InsertOrthomclOldGroupsMap", $args);

    unlink("tmpTaxonMap") if -e "tmpTaxonMap";
  }
}

# return hash of release to old abbrev, if any
sub parseOldAbbrevsList {
  my ($self, $oldAbbrevsList, $abbrev) = @_;
  my @oldAbbrevs = split(/,\s*/, $oldAbbrevsList);
  my $answer;
  foreach my $oldAbbrev (@oldAbbrevs) {
    $oldAbbrev =~ /(\d+)\:(\w+)/ || $self->error("oldAbbrevsList '' is not in correct format.  Must be like this:  '3:pfa, 4:pfa'");
    my $release = $1;
    my $abb = $2;
    $answer->{$release} = $abb;
  }
  return $answer;
}

