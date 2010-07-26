package Zenra::Schema::Result::Status;
use strict;
use warnings;
use base 'Zenra::Schema::ResultBase';

__PACKAGE__->table('status');
__PACKAGE__->add_columns(
    id => {
        data_type   => 'BIGINT',
        is_nullable => 0,
    },
    text => {
        data_type   => 'TEXT',
        is_nullable => 0,
    },
    screen_name => {
        data_type   => 'VARCHAR',
        size        => 20,
        is_nullable => 0,
    },
    name => {
        data_type   => 'VARCHAR',
        size        => 64,
        is_nullable => 0,
    },
    profile_image => {
        data_type   => 'VARCHAR',
        size        => 255,
        is_nullable => 0,
    },
    created_at => {
        data_type   => 'DATETIME',
        is_nullable => 0,
        timezone    => __PACKAGE__->TZ,
    },
    protected => {
        data_type     => 'TINYINT',
        size          => 1,
        is_nullable   => 1,
        default_value => 0,
    },
    short_url => {
        data_type   => 'VARCHAR',
        size        => 32,
        is_nullable => 1,
    },
);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->has_many(favorites => 'Zenra::Schema::Result::Favorite', 'status');
__PACKAGE__->many_to_many(users => 'favorites', 'user');

1;
