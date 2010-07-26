package Zenra::Schema::Result::Favorite;
use strict;
use warnings;
use base 'Zenra::Schema::ResultBase';
use DateTime;

__PACKAGE__->table('favorite');
__PACKAGE__->add_columns(
    id => {
        data_type   => 'INTEGER',
        is_nullable => 0,
        extra => {
            unsigned => 1,
        },
    },
    user => {
        data_type   => 'INTEGER',
        is_nullable => 0,
        extra => {
            unsigned => 1,
        },
    },
    status => {
        data_type   => 'BIGINT',
        is_nullable => 0,
    },
    created_at => {
        data_type   => 'DATETIME',
        is_nullable => 0,
        timezone    => __PACKAGE__->TZ,
    },
);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint('user_status', ['user', 'status']);
__PACKAGE__->belongs_to(user   => 'Zenra::Schema::Result::User'  );
__PACKAGE__->belongs_to(status => 'Zenra::Schema::Result::Status');

sub insert {
    my ($self) = @_;

    $self->created_at(DateTime->now);
    $self->next::method(@_);
}

1;
