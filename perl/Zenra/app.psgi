use Plack::Builder;
use Plack::Middleware::Static;

use FindBin::libs;
use Zenra;

my $app = Zenra->new;
$app->setup_minimal;

builder {
    enable 'Plack::Middleware::Static',
        path => qr{^/(js/|css/|swf/|images?/|imgs?/|static/|favicon\.ico$)},
        root => $app->path_to('root')->stringify;

    $app->handler;
};
