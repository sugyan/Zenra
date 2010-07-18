package Zenra::Controller::Root;
use Ark 'Controller';
use Encode qw/encode_utf8 decode_utf8/;
use Net::Twitter::Lite;
use List::Util 'shuffle';
use Try::Tiny;
use Zenra::Models;

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
        $c->forward($c->view('MT'));
    }
}

sub index :Path :Args(0) {
    my ($self, $c) = @_;
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
    my ($access_token, $access_token_secret, $user_id, $screen_name);
    my $error;
    try {
        ($access_token, $access_token_secret, $user_id, $screen_name) =
            $ntl->request_access_token(
                token_secret => '',
                token        => $token,
                verifier     => $verifier,
            );
        $ntl->access_token($access_token);
        $ntl->access_token_secret($access_token_secret);

        my $statuses = $ntl->user_timeline({count => 200});
        for my $status (shuffle @$statuses) {
            next if $status->{in_reply_to_status_id};

            my $zenra    = decode_utf8 models('util')->zenra;
            my $zenrized = decode_utf8 models('util')->zenrize(encode_utf8 $status->{text});
            next unless ($zenrized =~ /$zenra/);

            my $text = "\@${screen_name}が以前にも全裸で言ったけど: $zenrized #zenra";
            next if length($text) > 140;

            $ntl->update({
                status => $text,
                in_reply_to_status_id => $status->{id},
            });

            last;
        }
    } catch {
        $error = $_;
    };
    $c->detach('/index') if $error;

    $c->redirect("http://twitter.com/$screen_name");
}

__PACKAGE__->meta->make_immutable;

1;
