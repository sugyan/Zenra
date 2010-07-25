package Zenra::Controller::Root;
use Ark 'Controller';

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

__PACKAGE__->meta->make_immutable;

1;
