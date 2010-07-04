#!/usr/bin/perl
my $path_to_app;
BEGIN {
    $path_to_app = 'path/to/app';
}

use lib "$path_to_app/lib";
use Plack::Loader;
my $app = Plack::Util::load_psgi("$path_to_app/app.psgi");
Plack::Loader->auto->run($app);
