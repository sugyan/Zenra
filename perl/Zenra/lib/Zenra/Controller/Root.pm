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

    my $tw = $c->model('twitter', "hoge");
    $tw->access_token($c->user->obj->access_token);
    $tw->access_token_secret($c->user->obj->access_token_secret);

    my $zenra = $c->model('util')->zenra;
    for my $status (@{ $tw->home_timeline }) {
        if (my $data = $c->model('Schema::Status')->find($status->{id})) {
            push @{ $c->stash->{statuses} }, +{ $data->get_columns };
            next;
        }
        my $zenrized_text = $c->model('util')->zenrize(encode_utf8 $status->{text});
        if ($zenrized_text =~ $zenra) {
            my $data = $c->model('Schema::Status')->create({
                id            => $status->{id},
                text          => decode_utf8($zenrized_text),
                screen_name   => $status->{user}{screen_name},
                profile_image => $status->{user}{profile_image_url},
                created_at    => $c->model('parser')->($status->{created_at}),
                protected     => $status->{protected},
            });
            push @{ $c->stash->{statuses} }, +{ $data->get_columns };
            next;
        }
        push @{ $c->stash->{statuses} }, $status;
    }

    $c->stash->{remaining} = $tw->rate_remaining;
}

__PACKAGE__->meta->make_immutable;

1;
