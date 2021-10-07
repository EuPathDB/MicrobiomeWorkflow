use strict;
use warnings;


use lib "$ENV{GUS_HOME}/lib/perl";

use MicrobiomeWorkflow::Main::WorkflowSteps::DecorateEukdetectResultsWithTaxa;
use ReFlow::Controller::WorkflowHandle;

my ($input, $output) = @ARGV;
die "Usage: $0 input output" unless -f $input and $output;

my $t = MicrobiomeWorkflow::Main::WorkflowSteps::DecorateEukdetectResultsWithTaxa->new();

$t->setWorkflow(ReFlow::Controller::WorkflowHandle->new(".", "mbio-inc"));

$t->decorateFile($input, $output);
