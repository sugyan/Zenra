package Zenra::Controller::User;
use Ark 'Controller';
use Try::Tiny;

sub auto :Private {
    my ($self, $c) = @_;

    $c->redirect_and_detach('/') unless $c->user;
}

sub index :Path :Args(1) {
    my ($self, $c, $args) = @_;

    my $tw = $c->model('twitter');
    $tw->access_token($c->user->obj->access_token);
    $tw->access_token_secret($c->user->obj->access_token_secret);

    my $timeline;
    try {
        $timeline = $tw->user_timeline({ id => $args });
    } catch {
        $c->detach('/default');
    };
    $c->forward('/process_statuses', $timeline);
    $c->stash->{screen_name} = $args;
    $c->stash->{remaining} = $tw->rate_remaining;
}

__PACKAGE__->meta->make_immutable;

1;
