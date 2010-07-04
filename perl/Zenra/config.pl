return {
    twitter => {
        oauth => {
            consumer_key    => '****',
            consumer_secret => '****',
        },
        callback_url    => 'http://example.com/',
    },
    mecab => {
        dicdir => 'path/to/dic',
    },
};
