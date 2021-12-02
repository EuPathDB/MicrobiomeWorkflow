use strict;
use warnings;
use feature 'say';

# usage: pipe in a list of taxa
# pipe out to a temporary file
# cut -f 1 /eupath/data/EuPathDB/workflows/MicrobiomeDB/5/data/all_results/*.eukdetect.lineage_abundance.tsv | sort -u

my $owl = "";

my $xml = "";


my $c = 0001;
while(<>){
  chomp;
  my ($lineage) = split "\t";
  next if $lineage eq 'lineage';
  my @ls = split ";", $lineage;
  my $kingdom = shift @ls;
  @ls = reverse @ls;
  my $name = shift @ls;
  next unless $name;
  
  my $id1 = "TMP_EUKDETECT_M_" . $c++; 
  
  $owl .= owlStanza($id1, "$name detected", parentTerm($kingdom));  
  $xml .= xmlStanza($id1, "$name detected");

  my $id2 = "TMP_EUKDETECT_C_" . $c; 

  $owl .= owlStanza($id2, "Matches for $name (CPM)", "EUPATH_0009269");  
  $xml .= xmlStanza($id2, "Matches for $name (CPM)");
}

say $owl;
say $xml;

sub parentTerm {
  my ($kingdom) = @_;
  return $kingdom eq "Viridiplantae" ? 'EUPATH_0009264'
    : $kingdom eq "Metazoa" ? 'EUPATH_0009265'
    : $kingdom eq "Fungi" ? 'EUPATH_0009268'
    : "EUPATH_0009266"; #protist
}

sub owlStanza {
  my ( $id, $name, $parent) =@_;
  my $result = <<"EOF";

    <owl:Class rdf:about="http://purl.obolibrary.org/obo/$id">
        <rdfs:subClassOf rdf:resource="http://purl.obolibrary.org/obo/$parent"/>
        <rdfs:label rdf:datatype="http://www.w3.org/2001/XMLSchema#string">$name</rdfs:label>
    </owl:Class>
EOF
  return $result;
}
sub xmlStanza {
  my ($id, $name) = @_;
my $result = <<"EOF";

  <ontologyTerm source_id="$id" type="characteristicQualifier" parent="Source">
    <name>$name</name>
  </ontologyTerm>
EOF
  return $result;
}
