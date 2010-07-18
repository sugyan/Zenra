package Zenra;
use Ark;

our $VERSION = '0.01';

use_model 'Zenra::Models';

use_plugins qw/
    Authentication
    Authentication::Credential::Twitter
    Authentication::Store::DBIx::Class
    Session
    Session::State::Cookie
    Session::Store::Model
/;

__PACKAGE__->meta->make_immutable;

1;
