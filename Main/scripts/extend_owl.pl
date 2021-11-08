use strict;
use warnings;
use feature 'say';

# usage: pipe in a list of taxa
# pipe out to a temporary file
# cut -f 1 /eupath/data/EuPathDB/workflows/MicrobiomeDB/5/data/all_results/*.eukdetect.lineage_abundance.tsv | sort -u

my $owl = '
    <owl:Class rdf:about="http://purl.obolibrary.org/obo/TMP_EUKDETECT_ORIGINAL">
        <rdfs:subClassOf rdf:resource="http://purl.obolibrary.org/obo/OGMS_0000056"/>
        <rdfs:label rdf:datatype="http://www.w3.org/2001/XMLSchema#string">EukDetect original result</rdfs:label>
    </owl:Class>
';

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
  my $p = parentTerm($kingdom);
  
  my $id = "TMP_EUKDETECT_ORIGINAL_" . $c++; 
  
  $owl .= owlStanza($id, $name, parentTerm($kingdom));  
  $xml .= xmlStanza($id, $name);
}

say $owl;
say $xml;

sub parentTerm {
  my ($kingdom) = @_;
  return "TMP_EUKDETECT_ORIGINAL";
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
        <rdfs:label rdf:datatype="http://www.w3.org/2001/XMLSchema#string">$name originally detected</rdfs:label>
    </owl:Class>
EOF
  return $result;
}
sub xmlStanza {
  my ($id, $name) = @_;
my $result = <<"EOF";

  <ontologyTerm source_id="$id" type="characteristicQualifier" parent="Assay">
    <name>Original:$name</name>
  </ontologyTerm>
EOF
  return $result;
}
