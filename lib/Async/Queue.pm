package Async::Queue;

use strict;
use warnings;

sub new {
    my $class = shift;

    my $self = {@_};
    bless $self, $class;

    die 'worker is required' unless $self->{worker};
    die 'worker must be a CODEREF' unless ref $self->{worker} eq 'CODE';

    $self->{max_workers} ||= 0;
    $self->{workers} = 0;

    $self->{on_eoq} ||= sub {};

    return $self;
}

sub push_queue {
    my $self = shift;

    push @{$self->{queue}}, @_;

    $self->_start_workers;

    return $self;
}

sub done {
    my $self = shift;

    $self->{workers}--;

    if (@{$self->{queue}} || $self->{workers}) {
        $self->_start_workers;
    }
    else {
        $self->{on_eoq}->($self);
    }
}

sub _start_workers {
    my $self = shift;

    while ($self->_need_workers) {
        $self->{workers}++;
        $self->{worker}->($self, shift @{$self->{queue}});
    }
}

sub _need_workers {
    my $self = shift;

    my $need = @{$self->{queue}};

    if ($self->{max_workers}) {
        my $diff = $self->{max_workers} - $self->{workers};
        $need = $diff if $need > $diff;
    }

    return $need;
}

1;
