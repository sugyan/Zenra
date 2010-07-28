use Zenra::Models;

my $home = Zenra::Models->get('home');

return {
    domain => 'sugyan.sakura.ne.jp',
    bitly => {
        base_url => 'http://api.bit.ly',
        param => {
            login    => '****',
            apiKey   => '********',
            format   => 'xml',
        },
    },
    cache => {
        class => 'Cache::FastMmap',
        deref => 1,
        args  => {
            share_file     => $home->subdir('tmp')->file('cache')->stringify,
            unlink_on_exit => 0,
        },
    },
    database => [
        'dbi:mysql:zenra',
        'root',
        '',
        {
            mysql_enable_utf8 => 1,
            on_connect_do     => ['SET NAMES utf8'],
        },
    ],
    mecab => {
        dicdir => 'path/to/dic',
    },
    'Plugin::Authentication::Credential::Twitter' => {
        consumer_key    => '****',
        consumer_secret => '********',
    },
    'Plugin::Authentication::Store::DBIx::Class' => {
        model      => 'Schema',
        user_field => 'id',
    },
    'Plugin::Session::Store::Model' => {
        model => 'cache',
    },
};
