package Zenra::Schema::ResultBase;
use strict;
use warnings;
use base 'DBIx::Class';

use DateTime;
use DateTime::TimeZone;

__PACKAGE__->load_components(qw/InflateColumn::DateTime Core/);

{
    my $TZ;
    sub TZ {
        $TZ ||= DateTime::TimeZone->new( name => 'Asia/Tokyo' );
    }
}

sub sqlt_deploy_hook {
    my ($self, $sqlt_schema) = @_;

    $sqlt_schema->extra(
        mysql_charset    => 'utf8',
    );
}

1;
