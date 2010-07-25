use inc::Module::Install;
name 'Zenra';
all_from 'lib/Zenra.pm';

requires 'Ark';

requires 'Cache::FastMmap';
requires 'Data::UUID';
requires 'Date::Parse';
requires 'DateTime::Format::MySQL';
requires 'Digest::SHA1';
requires 'Net::Twitter';
requires 'Text::MeCab';
requires 'Try::Tiny';

tests 't/*.t';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
