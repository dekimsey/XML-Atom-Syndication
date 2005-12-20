# $Id: 04-person.t,v 1.1 2004/05/08 13:20:58 btrott Exp $

use strict;

use Test;
use XML::Atom::Syndication::Person;

BEGIN { plan tests => 9 };

my $person;

$person = XML::Atom::Syndication::Person->new;
ok($person);
ok($person->elem);

$person->name('Foo Bar');
ok($person->name, 'Foo Bar');
$person->name('Baz Quux');
ok($person->name, 'Baz Quux');

$person->email('foo@bar.com');
ok($person->email, 'foo@bar.com');

my $xml = $person->as_xml;
ok($xml =~ /^<\?xml version="1.0" encoding="utf-8"\?>/);
ok($xml =~ m!<author xmlns="http://www.w3.org/2005/Atom">!);
ok($xml =~ m!<name>Baz Quux</name>!);
ok($xml =~ m!<email>foo\@bar.com</email>!);
