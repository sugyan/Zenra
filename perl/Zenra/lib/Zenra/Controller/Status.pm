package Zenra::Controller::Status;
use Ark 'Controller';
use Try::Tiny;

sub index :Path :Args(1) {
    my ($self, $c, $args) = @_;

    $c->stash->{status} = $c->model('Schema::Status')->find($args)
        or $c->detach('/default');
}

__PACKAGE__->meta->make_immutable;

1;
