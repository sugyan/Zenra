package Zenra::Controller::API::Tweet;
use Ark 'Controller';
use Try::Tiny;

sub index :Path :Args(0) {
    my ($self, $c) = @_;

    my $status = $c->model('Schema::Status')->find($c->req->param('id'))
        or $c->detach('/default');
    $c->detach('/default') if $status->protected;

    try {
        # TODO
        $c->log(debug => $status->text);
    } catch {
        my $error = $_;
        $c->log(error => $error);
        $c->stash->{json}{error} = ref $error;
    };
}

__PACKAGE__->meta->make_immutable;

1;
