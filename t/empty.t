use strict;
use warnings;

use Test::More tests => 2;

use_ok('Async::Workers');

my $i = 0;

my $q = Async::Workers->new(
    worker => sub {
        my $q = shift;
        my ($arg) = @_;

        $i += $arg;

        $q->done;
    },
    on_eoq => sub {
        is $i => 0;
    }
);

$q->push_queue();
