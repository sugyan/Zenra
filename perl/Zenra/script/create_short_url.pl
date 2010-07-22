#!/usr/bin/perl
use strict;
use warnings;

use FindBin::libs;
use Zenra::Models;

use WebService::Simple;

my $bitly = WebService::Simple->new(
    base_url => 'http://api.bit.ly',
    param    => models('conf')->{bitly},
);

my $targets = models('Schema::Spread')->search({
    shorten => 0,
});
while (my $target = $targets->next) {
    my $status   = $target->status;
    my $long_url = 'http://' . models('conf')->{domain} . '/status/' . $status->id;
    my $result   = $bitly->get('/v3/shorten', {
        longUrl => $long_url,
        format  => 'xml',
    })->parse_response;

    if (my $short_url = $result->{data}{url}) {
        my $guard = models('Schema')->txn_scope_guard;
        $status->update({ short_url => $short_url });
        $target->update({ shorten   => 1          });
        $guard->commit;
    }
}
