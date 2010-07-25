package Zenra::View::JSON;
use Ark 'View::JSON';

has '+expose_stash' => (
    default => 'json',
);

1;
