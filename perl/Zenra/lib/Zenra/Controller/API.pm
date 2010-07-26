package Zenra::Controller::API;
use Ark 'Controller';
use Encode qw/encode_utf8 decode_utf8/;

sub auto :Private {
    my ($self, $c) = @_;

    $c->detach('/default') unless $c->user;
    my $token = $c->req->param('token');
    unless ($token && $token eq $c->user->obj->token) {
        $c->detach('/default');
    }
}

sub process_statuses :Private {
    my ($self, $c, $statuses) = @_;

    my $zenra = $c->model('util')->zenra;
    my $results = [];
    for my $status (@$statuses) {
        my $zenrized_text = $c->model('util')->zenrize(encode_utf8($status->{text}));
        my $params = {
            id            => $status->{id},
            text          => decode_utf8($zenrized_text),
            screen_name   => $status->{user}{screen_name},
            name          => $status->{user}{name},
            profile_image => $status->{user}{profile_image_url},
            protected     => $status->{user}{protected},
            created_at    => $c->model('parser')->($status->{created_at})->strftime('%Y/%m/%d %H:%M:%S'),
        };
        if ($zenrized_text =~ $zenra) {
            my $status = $c->model('Schema::Status')->update_or_create({ %$params });
            $params->{favorited} = ($c->user && $status->users->find($c->user->obj->id)) ? 1 : 0;
        }
        else {
            $params->{no_zenra} = 1;
        }
        push @$results, $params;
    }

    return $results;
}

sub end :Private {
    my ($self, $c) = @_;

    if ($c->stash->{json}) {
        $c->forward($c->view('JSON'));
    }
}

__PACKAGE__->meta->make_immutable;

1;
