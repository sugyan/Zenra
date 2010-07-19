? extends 'common/base';

? block title => sub { $c->stash->{screen_name} . ' - ' . super() }

? block content => sub { include('common/statuses') }
