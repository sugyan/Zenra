package Zenra::Controller::Spread;
use Ark 'Controller';
use Try::Tiny;

sub auto :Private {
    my ($self, $c) = @_;

    $c->redirect_and_detach('/') unless $c->user;
}

sub index :Path :Args(0) {
    my ($self, $c) = @_;

    my $status = $c->model('Schema::Status')->find($c->req->param('id'))
        or $c->detach('/default');
    $c->detach('/default') unless ($c->req->method eq 'POST');
    $c->detach('/default') if $status->protected;

    my $tw = $c->model('twitter');
    $tw->access_token($c->user->obj->access_token);
    $tw->access_token_secret($c->user->obj->access_token_secret);

    my $spread = $status->spreads->find({
        user   => $c->user->obj->id,
    }, {
        key => 'user_status',
    });

    my $tweeted;
    if ($spread) {
        try {
            $tw->destroy_status($spread->id);
        } catch {
            $c->log(error => $_);
        };
        $spread->delete;
    } else {
        my $text = sprintf '@%sが #zenra で言った: %s', (
            $status->screen_name,
            $status->text,
        );
        my $url = $status->short_url
            || 'http://' . $c->model('conf')->{domain} . '/status/' . $status->id;
        if ((my $over = length($text) + length($url) + 1 - 140) > 0) {
            $text = substr($text, 0, length($text) - $over - 3) . '...';
        }
        $text .= " $url";
        try {
            my $result = $tw->update({
                status => $text,
                in_reply_to_status_id => $status->id,
            });
            $status->add_to_users($c->user->obj, {
                id => $result->{id},
            });
            $tweeted = $result;
        } catch {
            $c->log(error => $_);
        };
    }

    # とりあえず拡散成功したときだけTwitterに飛ばす
    if ($tweeted) {
        $c->redirect_and_detach("http://twitter.com/$tweeted->{user}{screen_name}/status/$tweeted->{id}");
    }
    else {
        $c->redirect_and_detach('/home');
    }
}

__PACKAGE__->meta->make_immutable;

1;
