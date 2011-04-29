use strict;
use warnings;

use Test::More tests => 2;

use_ok('Async::Queue');

my $i = 0;

my $q = Async::Queue->new(
    max_workers => 2,
    worker      => sub {
        my $q = shift;
        my ($arg) = @_;

        $i += $arg;

        $q->done;
    },
    on_eoq => sub {
        is $i => 6;
    }
);

$q->push_queue(1, 2, 3);
