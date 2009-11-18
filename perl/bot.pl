#!perl
use strict;
use warnings;

use Coro;
use Coro::AnyEvent;
use Config::Any::YAML;
use Date::Parse 'str2time';
use Encode 'encode_utf8';
use List::Util qw/max shuffle/;
use Net::Twitter::Lite;
use Text::MeCab;

my $twitter = do {
    my $config = Config::Any::YAML->load('config.yaml');
    Net::Twitter::Lite->new(%$config);
};

my $cv = AE::cv;
# 5分毎にfollower/friendsを更新
async {
    while (1) {
        Coro::AnyEvent::sleep 300;
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
    }
};
# friends_timelineからランダムに発言を拾って全裸にする
async {
    while (1) {
        my $sleep = 60;
        eval {
            my $statuses = $twitter->friends_timeline({ count => 100 });
            if (@$statuses > 1) {
                # 最新と最古のstatusの時差を計測、次の更新へのwait時間とする
                my $oldest = str2time($statuses->[-1]{created_at});
                my $newest = str2time($statuses->[ 0]{created_at});
                $sleep = max($sleep, $newest - $oldest);
            }
          ZENRIZE:
            for my $status (shuffle @$statuses) {
                my $text = encode_utf8 $status->{text};
                next if $status->{user}{screen_name} eq 'zenra_bot2';
                next if $status->{user}{protected};
                next if $text =~ / RT[ :] .* \@ \w+ /xms;
                next if $text =~ / [\#＃]\w+ /xms;
                next if $text =~ / 全裸で /xms;

                my $zenrized = zenrize_all($text);
                if ($text ne $zenrized) {
                    $twitter->update({
                        status => "\@$status->{user}{screen_name} が全裸で呟いた: $zenrized",
                        in_reply_to_status_id => $status->{id},
                    });
                    last ZENRIZE;
                }
            }
        };
        Coro::AnyEvent::sleep($sleep);
    }
};
# 独り言
async {
    while (1) {
        Coro::AnyEvent::sleep(7200 + rand 7200);
        eval {
            my $data = Config::Any::YAML->load('update.yaml');
            my $status = (shuffle @{$data->{self}})[0];
            $twitter->update($status);
        };
    }
};
# replyへの反応もできるようにする？

$cv->recv;

# テキスト全体を全裸にする
sub zenrize_all {
    my $text = shift;

    my $result = '';
    for my $sentence (split/(\s+)/, $text) {
        $result .= $sentence =~ /\s+/ ?
          $sentence : zenrize($sentence);
    }
    return $result;
}

# 日本語の文章を全裸にする
sub zenrize {
    my $sentence = shift;

    my $zenra  = '全裸で';
    my $mecab  = Text::MeCab->new();
    my $result = '';
    my $n = $mecab->parse($sentence);

    # 末尾まで進める
    $n = $n->next while ($n->next);

    my $flg = 0;
    # 末尾からさかのぼる
    while (($n = $n->prev)->prev) {
        # フラグがたっていれば「全裸で」を挿入
        # ただし、名詞／副詞／動詞のときはまだ挿入しない
        if ($flg) {
            my $insert = 1;
            if ($n->feature =~ / \A (名詞|副詞|動詞) /xms) {
                $insert = 0;
            }
            # また、連用形の動詞→助(動)詞の場合も挿入しない
            elsif ($n->feature =~ / \A 助(動)?詞 /xms &&
                       (split(/,/, $n->prev->feature))[5] =~ / 連用 /xms) {
                $insert = 0;
            }
            if ($insert) {
                $result = $zenra . $result;
                $flg = 0;
            }
        }
        # 出力の連結
        $result = $n->surface . $result;
        # 動詞を検出してフラグをたてる
        if ($n->feature =~ / \A 動詞 /xms) {
            $flg = 1;
        }
    }
    # 先頭のチェック
    if ($flg) {
        $result = $zenra . $result;
    }

    return $result;
}
