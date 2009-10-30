#!/opt/local/bin/perl
use strict;
use warnings;

use AnyEvent;
use AnyEvent::Twitter::Stream;
use Config::Any::YAML;
use Encode 'decode_utf8';
use Net::Twitter::Lite;

my $config = Config::Any::YAML->load('config.yaml');
my $twitter = Net::Twitter::Lite->new(%$config);

my $cv = AE::cv;
# 5分毎にfollower/friendsを更新
# my $follow = AE::timer 0, 300, sub {
AE::timer 0, 300, sub {
    eval {
        my $friends   = $twitter->friends_ids;
        my $followers = $twitter->followers_ids;
        # 差分を検出
        my %ids = map +( $_ => 1 ), @$friends;
        for my $id (@$followers) {
            my $result = delete $ids{$id};
            # 未フォローユーザをフォローする
            if (!defined $result) {
                $twitter->create_friend($id);
            }
        }
        # 残りはリムーブすべきユーザ
        for my $id (keys %ids) {
            $twitter->destroy_friend($id);
        }
    };
};
my $x; $x = AE::timer 0, 2, sub {
#     my $statuses = $twitter->home_timeline;
};

# my $listener = AnyEvent::Twitter::Stream->new(
#     %$config,
#     method   => "filter",
#     track    => 'zenra',
#     on_tweet => sub {
#         my $tweet = shift;
#         warn "$tweet->{user}{screen_name}: $tweet->{text}\n";
#     },
# );

$cv->recv;
