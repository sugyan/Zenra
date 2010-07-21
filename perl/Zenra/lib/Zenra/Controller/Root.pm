package Zenra::Controller::Root;
use Ark 'Controller';
use Encode qw/encode_utf8 decode_utf8/;

has '+namespace' => default => '';

# default 404 handler
sub default :Path :Args {
    my ($self, $c) = @_;

    $c->res->status(404);
    $c->res->body('404 Not Found');
}

# view renderer
sub end :Private {
    my ($self, $c) = @_;

    unless ($c->res->body or $c->res->status =~ /^3\d\d/) {
        $c->res->content_type('text/html');
        $c->forward($c->view('MT'));
    }
}

sub index :Path :Args(0) {
    my ($self, $c) = @_;
}

sub home :Local :Args(0) {
    my ($self, $c) = @_;

    $c->redirect_and_detach('/') unless $c->user;

    my $tw = $c->model('twitter');
    $tw->access_token($c->user->obj->access_token);
    $tw->access_token_secret($c->user->obj->access_token_secret);

    $c->forward('/process_statuses', $tw->home_timeline);
    $c->stash->{remaining} = $tw->rate_remaining;
}

sub process_statuses :Private {
    my ($self, $c, $statuses) = @_;

    my $zenra = $c->model('util')->zenra;
    for my $status (@$statuses) {
        my $zenrized_text = $c->model('util')->zenrize(encode_utf8 $status->{text});
        my $params = {
            id            => $status->{id},
            text          => decode_utf8($zenrized_text),
            screen_name   => $status->{user}{screen_name},
            name          => $status->{user}{name},
            profile_image => $status->{user}{profile_image_url},
            protected     => $status->{user}{protected},
            created_at    => $c->model('parser')->($status->{created_at}),
        };
        warn $params->{created_at};
        if ($zenrized_text =~ $zenra) {
            my $status = $c->model('Schema::Status')->update_or_create({ %$params });
            $params->{spread} = ($c->user && $status->users->find($c->user->obj->id)) ? 1 : 0;
        }
        else {
            $params->{no_zenra} = 1;
        }
        warn $params->{created_at};
        warn $params->{spread};
        push @{ $c->stash->{statuses} }, $params;
    }
}

__PACKAGE__->meta->make_immutable;

1;
