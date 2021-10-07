use strict;
use warnings;


use lib "$ENV{GUS_HOME}/lib/perl";

use Test::More;
use MicrobiomeWorkflow::Main::WorkflowSteps::DecorateEukdetectResultsWithTaxa;
use ReFlow::Controller::WorkflowHandle;

my $t = MicrobiomeWorkflow::Main::WorkflowSteps::DecorateEukdetectResultsWithTaxa->new();

$t->setWorkflow(ReFlow::Controller::WorkflowHandle->new(".", "mbio-inc"));
my ($input, $expected);
my $output = "";

$input = <<EOF;
taxon	s1
2570542|protist-Piridium_sociabile	0.1
114070|metazoa-Calanus_sinicus	0.2
2759|other_MGCollapse_EPSP3-12	0.3
242159|greenalgae-Ostreococcus_lucimarinus	0.4
223228|insect-Ferrisia_virgata	0.5
1290454|fungi-Mucor_irregularis_B50	0.6
35688|archaeplast-Porphyridium_purpureum	0.7
290746|worm-Acrobeloides_nanus	0.8
1337|t1	0.9
5778|protist-Vermamoeba_vermiformis	0.11
?246006|Suhomyces_emberorum,5486|Candida_viswanathii	0.12
?5778|protist-Vermamoeba_vermiformis	0.13
EOF

$expected = <<EOF;
lineage	s1
Bacteria;Firmicutes;Bacilli;Lactobacillales;Streptococcaceae;Streptococcus;Streptococcus hyointestinalis	0.9
Eukaryota;;;;;;	0.3
Eukaryota;;;;Vitrellaceae;Piridium;Piridium sociabile	0.1
Eukaryota;Rhodophyta;Bangiophyceae;Porphyridiales;Porphyridiaceae;Porphyridium;Porphyridium purpureum	0.7
Eukaryota;Tubulinea;Echinamoebida;;;Vermamoeba;	0.13
Eukaryota;Tubulinea;Echinamoebida;;;Vermamoeba;Vermamoeba vermiformis	0.11
Fungi;Ascomycota;Saccharomycetes;Saccharomycetales;Debaryomycetaceae;;	0.12
Fungi;Mucoromycota;Mucoromycetes;Mucorales;Mucoraceae;Mucor;Mucor irregularis	0.6
Metazoa;Arthropoda;Hexanauplia;Calanoida;Calanidae;Calanus;Calanus sinicus	0.2
Metazoa;Arthropoda;Insecta;Hemiptera;Pseudococcidae;Ferrisia;Ferrisia virgata	0.5
Metazoa;Nematoda;Chromadorea;Rhabditida;Cephalobidae;Acrobeloides;Acrobeloides nanus	0.8
Viridiplantae;Chlorophyta;Mamiellophyceae;Mamiellales;Bathycoccaceae;Ostreococcus;Ostreococcus sp. 'lucimarinus'	0.4
EOF
$t->decorateFile(\$input, \$output);

is($output, $expected, "small test file");

$input = <<EOF;
taxon	s1	s2	s3
1337|n1	0.05	0.2	
1337|n2	0.05		
1337|n3			0.3
EOF
$expected = <<EOF;
lineage	s1	s2	s3
Bacteria;Firmicutes;Bacilli;Lactobacillales;Streptococcaceae;Streptococcus;Streptococcus hyointestinalis	0.1	0.2	0.3
EOF


$t->decorateFile(\$input, \$output);

is($output, $expected, "Merge lines with same taxon");
