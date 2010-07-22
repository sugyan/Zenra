package Zenra::Models;
use strict;
use warnings;
use Ark::Models '-base';

register util => sub {
    my ($self) = @_;

    $self->ensure_class_loaded('Zenra::Models::Util');
    return Zenra::Models::Util->new;
};

register cache => sub {
    my ($self) = @_;

    my $conf = $self->get('conf')->{cache};
    return $self->adaptor($conf);
};

register mecab => sub {
    my ($self) = @_;

    my $conf = $self->get('conf')->{mecab};
    $self->ensure_class_loaded('Text::MeCab');
    return Text::MeCab->new(%$conf);
};

register twitter => sub {
    my ($self) = @_;

    my $conf = $self->get('conf')->{'Plugin::Authentication::Credential::Twitter'};
    $self->ensure_class_loaded('Net::Twitter');
    return Net::Twitter->new(
        traits => [qw/API::REST OAuth RateLimit/],
        %$conf,
    );
};

register parser => sub {
    my ($self) = @_;

    $self->ensure_class_loaded('DateTime');
    $self->ensure_class_loaded('Date::Parse');
    return sub {
        return DateTime->from_epoch(
            epoch     => Date::Parse::str2time($_[0]),
            time_zone => 'Asia/Tokyo',
        );
    };
};

register Schema => sub {
    my ($self) = @_;

    my $conf = $self->get('conf')->{database};
    $self->ensure_class_loaded('Zenra::Schema');
    return Zenra::Schema->connect(@$conf);
};

for my $table (qw/Status Spread/) {
    register "Schema::$table" => sub {
        my ($self) = @_;
        $self->get('Schema')->resultset($table);
    };
}

1;
