package Zenra::Schema::ResultBase;
use strict;
use warnings;
use base 'DBIx::Class::Core';

sub sqlt_deploy_hook {
    my ($self, $sqlt_schema) = @_;

    $sqlt_schema->extra(
        mysql_charset    => 'utf8',
    );
}

1;
