package Zenra::Controller::Root;
use Ark 'Controller';
use Net::Twitter::Lite;
use Zenra::Models;

has '+namespace' => default => '';

# default 404 handler
sub default :Path :Args {
    my ($self, $c) = @_;

    $c->res->status(404);
    $c->res->body('404 Not Found');
}

sub index :Path :Args(0) {
    my ($self, $c) = @_;
    $c->res->body('Ark Default Index');
}

sub zenrize :Local {
    my ($self, $c) = @_;

    my $ntl = Net::Twitter::Lite->new(
        %{models('conf')->{twitter}}
    );
    $c->redirect($ntl->get_authorization_url);
}

sub callback :Local {
    my ($self, $c) = @_;

    use YAML;
    $c->res->body(Dump $c->req->params);
}

1;
