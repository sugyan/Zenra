package Zenra::Controller::Home;
use Ark 'Controller';

sub auto :Private {
    my ($self, $c) = @_;

    $c->redirect_and_detach('/login') unless $c->user;
}

sub index :Path :Args(0) {}

__PACKAGE__->meta->make_immutable;

1;
