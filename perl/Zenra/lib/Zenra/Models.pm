package Zenra::Models;
use strict;
use warnings;
use Ark::Models '-base';

register util => sub {
    my ($self) = @_;

    $self->ensure_class_loaded('Zenra::Models::Util');
    return Zenra::Models::Util->new;
};

register cache => sub {
    my ($self) = @_;

    my $conf = $self->get('conf')->{cache};
    return $self->adaptor($conf);
};

register Schema => sub {
    my ($self) = @_;

    my $conf = $self->get('conf')->{database};
    $self->ensure_class_loaded('Zenra::Schema');
    return Zenra::Schema->connect(@$conf);
};

1;
