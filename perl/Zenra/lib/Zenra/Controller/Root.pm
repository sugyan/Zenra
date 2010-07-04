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

    my $token    = $c->req->param('oauth_token')    or $c->detach('/default');
    my $verifier = $c->req->param('oauth_verifier') or $c->detach('/default');

    my $ntl = Net::Twitter::Lite->new(
        %{ models('conf')->{twitter}{oauth} }
    );
    my ($access_token, $access_token_secret, $user_id, $screen_name) =
        $ntl->request_access_token(
            token_secret => '',
            token        => $token,
            verifier     => $verifier,
        );
    $ntl->access_token($access_token);
    $ntl->access_token_secret($access_token_secret);

    use YAML;
    $c->res->body(Dump $ntl->home_timeline);
}

1;
