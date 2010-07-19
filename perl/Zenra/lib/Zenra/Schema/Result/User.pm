package Zenra::Schema::Result::User;
use strict;
use warnings;
use base 'Zenra::Schema::ResultBase';

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
);
__PACKAGE__->set_primary_key('id');

1;
