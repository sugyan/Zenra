package Zenra::Controller::Status;
use Ark 'Controller';
use Try::Tiny;

sub index :Path :Args(1) {
    my ($self, $c, $args) = @_;

    my $status = $c->model('Schema::Status')->find($args)
        or $c->detach('/default');
    $c->detach('/default') if $status->protected;
    $c->stash->{status} = $status;

    my $fav = $c->user ? $c->model('Schema::Favorite')->find({
        user   => $c->user->obj->id,
        status => $status->id,
    }, 'user_status') : undef;
    $c->stash->{favorited} = $fav ? 1 : 0;
    $c->stash->{favorites} = $status->favorites->search(undef, {
        order_by => { -desc => 'created_at' },
    });
}

__PACKAGE__->meta->make_immutable;

1;
