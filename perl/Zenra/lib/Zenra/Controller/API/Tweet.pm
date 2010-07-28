package Zenra::Controller::API::Tweet;
use Ark 'Controller';
use Try::Tiny;

sub index :Path :Args(0) {
    my ($self, $c) = @_;

    my $status = $c->model('Schema::Status')->find($c->req->param('id'))
        or $c->detach('/default');
    $c->detach('/default') if $status->protected;

    try {
        $c->log(debug => $status->text);
        unless ($status->short_url) {
            my $bitly = $c->model('bitly')->get('/v3/shorten', {
                longUrl => 'http://' . $c->config->{domain} . '/status/' . $status->id,
            })->parse_response;
            $status->update({
                short_url => $bitly->{data}{url},
            });
        }
        my $text = sprintf '@%sが全裸で言った: %s', $status->screen_name, $status->text;
        my $url  = $status->short_url;
        if ((my $over = length($text) + length($url) + 1 - 140) > 0) {
            $text = substr($text, 0, length($text) - $over - 3) . '...';
        }
        $text .= " $url";

        my $tw = $c->model('twitter');
        $tw->access_token($c->user->obj->access_token);
        $tw->access_token_secret($c->user->obj->access_token_secret);
        $tw->update({
            status => $text,
            in_reply_to_status_id => $status->id,
        });
        $c->stash->{json}{result} = 'ok';
    } catch {
        my $error = $_;
        $c->log(error => $error);
        $c->stash->{json}{error} = ref $error;
    };
}

__PACKAGE__->meta->make_immutable;

1;
