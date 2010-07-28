package Zenra::Controller::Favorites;
use Ark 'Controller';

sub auto :Private {
    my ($self, $c) = @_;

    $c->redirect_and_detach('/login') unless $c->user;
}

sub index :Path :Args(0) {
    my ($self, $c) = @_;

    $c->stash->{favorites} = $c->model('Schema::Favorite')->search({
        user => $c->user->obj->id,
    }, {
        order_by => { -desc => 'created_at' },
        rows     => 20,
    });
}

__PACKAGE__->meta->make_immutable;

1;
