package OrthoMCLWorkflow::Main::WorkflowSteps::MapAndInsertPrevSeqIDs;

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

  while (my $releaseDir = readdir (DIR)) {
    next if ($releaseDir eq "." || $releaseDir eq "..");

    my $oldAbbrev = $abbrev;
    $oldAbbrev = $oldAbbrevs->{$releaseDir} if ($oldAbbrevs->{$releaseDir});

    next unless -e  "$workflowDataDir/$inputDir/$releaseDir/$oldAbbrev.fasta.gz";

    unlink("tmpAbbrevMap") if -e "tmpAbbrevMap";
    open(F, ">tmpAbbrevMap");
    print F "$oldAbbrev $abbrev\n";
    close(F);

    my $args = "--oldIdsFastaFile $workflowDataDir/$inputDir/$releaseDir/$oldAbbrev.fasta.gz --abbrevMapFile tmpAbbrevMap --oldReleaseNum $releaseDir";

    $self->runPlugin($test, $undo, "OrthoMCLData::Load::Plugin::InsertOrthomclOldIdsMap", $args);

    unlink("tmpAbbrevMap") if -e "tmpAbbrevMap";
  }
}

# return hash of release to old abbrev, if any
sub parseOldAbbrevsList {
  my ($self, $oldAbbrevsList, $abbrev) = @_;
  my @oldAbbrevs = split(/,\s*/, $oldAbbrevsList);
  my $answer;
  foreach my $oldAbbrev (@oldAbbrevs) {
    $oldAbbrev =~ /(\d+)\:(\w+)/ || $self->error("oldAbbrevsList '$oldAbbrev' is not in correct format.  Must be like this:  '3:pfa, 4:pfa'");
    my $release = $1;
    my $abb = $2;
    $answer->{$release} = $abb;
  }
  return $answer;
}

