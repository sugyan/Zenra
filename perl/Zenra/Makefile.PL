use inc::Module::Install;
name 'Zenra';
all_from 'lib/Zenra.pm';

requires 'Ark';

requires 'Net::Twitter::Lite';

tests 't/*.t';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
