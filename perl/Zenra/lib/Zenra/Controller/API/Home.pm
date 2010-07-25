package Zenra::Controller::API::Home;
use Ark 'Controller';

sub index :Path :Args(0) {
    my ($self, $c) = @_;

    my $tw = $c->model('twitter');
    $tw->access_token($c->user->obj->access_token);
    $tw->access_token_secret($c->user->obj->access_token_secret);

    $c->forward('/api/process_statuses', $tw->home_timeline);
    $c->stash->{json}{remaining} = $tw->rate_remaining;
}

__PACKAGE__->meta->make_immutable;

1;
