# $Id$

use strict;

use Test;
use XML::Atom::Syndication;
use XML::Atom::Syndication::Link;

BEGIN { plan tests => 14 };

my $link;

$link = XML::Atom::Syndication::Link->new;
ok($link);
ok($link->elem);

$link->title('This is a test.');
ok($link->title, 'This is a test.');
$link->title('Different title.');
ok($link->title, 'Different title.');
$link->title('This is a test.');

$link->rel('alternate');
ok($link->rel, 'alternate');

$link->href('http://www.example.com/');
ok($link->href, 'http://www.example.com/');

$link->type('text/html');
ok($link->type, 'text/html');

my $xml = $link->as_xml;
ok($xml =~ /^<\?xml version="1.0" encoding="utf-8"\?>/);
ok($xml =~ m!\bxmlns="http://www.w3.org/2005/Atom"!);
ok($xml =~ /title="This is a test."/);
ok($xml =~ /rel="alternate"/);
ok($xml =~ m!href="http://www.example.com/"!);
ok($xml =~ m!type="text/html"!);

my $ns = XML::Atom::Syndication::Namespace->new(dc => "http://purl.org/dc/elements/1.1/");
$link->set($ns, "subject" => "blah");

$xml = $link->as_xml;
ok($xml =~ m!dc:subject="blah"!);

