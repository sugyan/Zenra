package Zenra::Controller::Login;
use Ark 'Controller';

sub index :Path :Args(0) {
    my ($self, $c) = @_;

    my $auth = $c->auth->authenticate_twitter(
        callback => $c->uri_for('/login'),
    );
    $c->redirect_and_detach('/') if $auth;
}

__PACKAGE__->meta->make_immutable;

1;
