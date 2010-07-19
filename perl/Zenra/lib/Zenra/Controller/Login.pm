package Zenra::Controller::Login;
use Ark 'Controller';
use Try::Tiny;

sub index :Path :Args(0) {
    my ($self, $c) = @_;

    my $auth;
    if ($c->req->param('oauth_verifier')) {
        my $error;
        try {
            $auth = $c->auth->authenticate_twitter;
        } catch {
            $error = $_;
        };

        if ($error) {
            $c->log(error => $error);
            $c->redirect_and_detach('/login/failed');
        }
    }
    else {
        $auth = $c->auth->authenticate_twitter(
            callback => $c->uri_for('/login'),
        );
    }

    $c->redirect_and_detach('/home') if $auth;
}

sub failed :Local :Args(0) {
    my ($self, $c) = @_;

    $c->redirect_and_detach('/') if $c->user;
}

__PACKAGE__->meta->make_immutable;

1;
