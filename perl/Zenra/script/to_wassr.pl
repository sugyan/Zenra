#!/usr/bin/perl
use strict;
use warnings;

use utf8;
use Config::Pit;
use DateTime;
use LWP::UserAgent;
use FindBin::libs;
use Zenra::Models;

my $target_screen_name = 'sugyan';
my $wassr_config = pit_get('wassr.jp', require => {
    username => 'username',
    password => 'password',
});
my $ua = LWP::UserAgent->new;
$ua->credentials('api.wassr.jp:80', 'API Authentication', @{$wassr_config}{qw/username password/});

my $users = models('Schema::User');
my $user  = $users->search({ screen_name => $target_screen_name })->first;
my $tw = models('twitter');
$tw->access_token($user->access_token);
$tw->access_token_secret($user->access_token_secret);

my $now = DateTime->now(time_zone => 'Asia/Tokyo');
for my $status (@{ $tw->user_timeline }) {
    next if $status->{in_reply_to_user_id};
    next if $status->{in_reply_to_status_id};

    if ($now->delta_ms(models('parser')->($status->{created_at}))->delta_minutes < 3) {
        $ua->post('http://api.wassr.jp/statuses/update.json', {
            status => models('util')->zenrize($status->{text}),
            source => 'Twitterから転送',
        });
    }
}
