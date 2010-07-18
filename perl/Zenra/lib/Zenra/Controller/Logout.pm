package Zenra::Controller::Logout;
use Ark 'Controller';

sub index :Path :Args(0) {
    my ($self, $c) = @_;

    $c->logout;
    $c->redirect_and_detach('/');
}

__PACKAGE__->meta->make_immutable;

1;
