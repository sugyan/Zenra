package Zenra::Controller::Spread;
use Ark 'Controller';

sub auto :Private {
    my ($self, $c) = @_;

    $c->redirect_and_detach('/') unless $c->user;
}

sub index :Path :Args(0) {
    my ($self, $c) = @_;

    my $status = $c->model('Schema::Status')->find($c->req->param('id'))
        or $c->detach('/default');
    $c->detach('/default') unless ($c->req->method eq 'POST');
    $c->detach('/default') if $status->protected;

    $status->add_to_users($c->user->obj);
    $c->redirect_and_detach('/home');
}

__PACKAGE__->meta->make_immutable;

1;
