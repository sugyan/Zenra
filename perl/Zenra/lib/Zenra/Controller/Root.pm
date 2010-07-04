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

    my $tw_conf = models('conf')->{twitter};
    my $ntl = Net::Twitter::Lite->new(%{ $tw_conf->{oauth} });
    $c->redirect($ntl->get_authorization_url(callback => $tw_conf->{callback_url}));
}

sub callback :Local {
    my ($self, $c) = @_;

    use YAML;
    my $res = Dump $c->req->params;

    my $ntl = Net::Twitter::Lite->new(
        %{ models('conf')->{twitter}{oauth} }
    );
    my @results = $ntl->request_access_token(
        token_secret => '',
        token        => $c->req->param('oauth_token'),
        verifier     => $c->req->param('oauth_verifier'),
    );
    $c->res->body($res . "\n@results");
}

1;
