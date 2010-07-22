package Zenra::Controller::Status;
use Ark 'Controller';
use Try::Tiny;

sub index :Path :Args(1) {
    my ($self, $c, $args) = @_;

    my $status = $c->model('Schema::Status')->find($args)
        or $c->detach('/default');
    $c->detach('/default') if $status->protected;
    $c->stash->{status} = $status;
    $c->stash->{spread} = ($c->user && $status->users->find($c->user->obj->id)) ? 1 : 0;
    $c->stash->{spreads} = $status->spreads->search(undef, {
        order_by => { -desc => 'created_at' },
    });
}

__PACKAGE__->meta->make_immutable;

1;
