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
        $statuses = $tw->user_timeline({ screen_name => $args });
    } catch {
        my $error = $_;
        $c->log(error => $error);
        $c->stash->{json}{error} = ref $error;
    };

    if ($statuses) {
        $c->stash->{json}{statuses}  = $c->forward('/api/process_statuses', $statuses);
        $c->stash->{json}{user_info} = $statuses->[0]{user};
        my $description = $c->model('util')->zenrize($c->stash->{json}{user_info}{description});
        $c->stash->{json}{user_info}{description} = $description;
    }
    $c->stash->{json}{remaining} = $tw->rate_remaining;
}

__PACKAGE__->meta->make_immutable;

1;
