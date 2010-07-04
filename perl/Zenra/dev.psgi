#!/usr/bin/perl
use strict;
use warnings;

use lib 'lib';
use Zenra;

my $app = sub {
    my $app = Zenra->new;
    $app->setup;
    $app->handler->(@_);
};
