package Zenra::Schema::Result::User;
use strict;
use warnings;
use base 'Zenra::Schema::ResultBase';
use Digest::SHA1 qw/sha1_hex/;
use Zenra::Models;

__PACKAGE__->table('user');
__PACKAGE__->add_columns(
    id => {
        data_type   => 'INTEGER',
        is_nullable => 0,
        extra => {
            unsigned => 1,
        },
    },
    screen_name => {
        data_type   => 'VARCHAR',
        size        => 20,
        is_nullable => 0,
    },
    token => {
        data_type   => 'VARCHAR',
        size        => 40,
        is_nullable => 0,
    },
    access_token => {
        data_type   => 'VARCHAR',
        size        => 64,
        is_nullable => 0,
    },
    access_token_secret => {
        data_type   => 'VARCHAR',
        size        => 64,
        is_nullable => 0,
    },
    created_at => {
        data_type   => 'DATETIME',
        is_nullable => 0,
        timezone    => __PACKAGE__->TZ,
    },
    updated_at => {
        data_type   => 'DATETIME',
        is_nullable => 0,
        timezone    => __PACKAGE__->TZ,
    },
);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->has_many(favorites => 'Zenra::Schema::Result::Favorite', 'user');
__PACKAGE__->many_to_many(statuses => 'favorites', 'status');

sub insert {
    my $self = shift;

    my $now = DateTime->now;
    $self->created_at($now);
    $self->updated_at($now);
    $self->token(sha1_hex(models('uuid')->create));

    $self->next::method(@_);
}

sub update {
    my $self = shift;

    $self->updated_at(DateTime->now);
    $self->token(sha1_hex(models('uuid')->create)) unless $self->token;

    $self->next::method(@_);
}

1;
