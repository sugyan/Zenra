package Zenra::Models;
use strict;
use warnings;
use Ark::Models '-base';

register util => sub {
    my ($self) = @_;
    $self->ensure_class_loaded('Zenra::Models::Util');
    Zenra::Models::Util->new;
};

1;
