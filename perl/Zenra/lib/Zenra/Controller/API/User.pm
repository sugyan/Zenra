package Zenra::Controller::API::User;
use Ark 'Controller';
use Try::Tiny;

sub index :Path :Args(1) {
    my ($self, $c, $args) = @_;

    my $tw = $c->model('twitter');
    $tw->access_token($c->user->obj->access_token);
    $tw->access_token_secret($c->user->obj->access_token_secret);

    my $statuses;
    try {
        $statuses = $tw->user_timeline({ id => $args });
    } catch {
        my $error = $_;
        $c->log(error => $error);
        $c->stash->{json}{error} = $error->message;
    };

    $c->forward('/api/process_statuses', $statuses);
    $c->stash->{json}{remaining} = $tw->rate_remaining;
}

__PACKAGE__->meta->make_immutable;

1;
