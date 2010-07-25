package Zenra::Controller::User;
use Ark 'Controller';
use Try::Tiny;

sub auto :Private {
    my ($self, $c) = @_;

    $c->redirect_and_detach('/login') unless $c->user;
}

sub index :Path :Args(1) {
    my ($self, $c, $args) = @_;

    $c->stash->{screen_name} = $args;
}

__PACKAGE__->meta->make_immutable;

1;
