package Zenra::Controller::API::Favorite;
use Ark 'Controller';
use Try::Tiny;

sub index :Path :Args(0) {
    my ($self, $c) = @_;

    my $status = $c->model('Schema::Status')->find($c->req->param('id'))
        or $c->detach('/default');

    try {
        my $fav = $c->model('Schema::Favorite')->find({
            user   => $c->user->obj->id,
            status => $status->id,
        }, 'user_status');
        if ($fav) {
            $fav->delete;
            $c->stash->{json}{result} = 'deleted';
        } else {
            $c->user->obj->add_to_statuses($status);
            $c->stash->{json}{result} = 'created';
        }
    } catch {
        my $error = $_;
        $c->log(error => $error);
        $c->stash->{json}{error} = ref $error;
    };
}

__PACKAGE__->meta->make_immutable;

1;
