#!/usr/bin/perl
use strict;
use warnings;

use lib 'lib';
use Zenra;
use Zenra::Models 'M';

use Plack::App::Directory;

my $root   = M('home')->subdir('root');
my $static = Plack::App::Directory->new({
   root => $root->stringify,
});

my $app = sub {
    my ($env) = @_;

    if (-f -r $root->file($env->{PATH_INFO})) {
        return $static->(@_);
    }
    else {
        my $app = Zenra->new;
        $app->setup_minimal;
        $app->handler->(@_);
    }
};
