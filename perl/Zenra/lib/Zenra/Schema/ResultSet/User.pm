package Zenra::Schema::ResultSet::User;
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

sub find_user {
    my ($self, $id, $info) = @_;

    my $user = $self->find_or_new({
        id => $id,
    });
    delete $info->{user_id};
    $user->set_columns($info);
    $user->update_or_insert;

    return $user;
}

1;
