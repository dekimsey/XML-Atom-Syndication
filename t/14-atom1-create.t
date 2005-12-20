# $Id$
use strict;
use XML::Atom::Syndication;
use XML::Atom::Syndication::Feed;
use XML::Atom::Syndication::Link;
use XML::Atom::Syndication::Entry;
use Test::More tests => 1;

my $feed = XML::Atom::Syndication::Feed->new(Version => 1.0);
$feed->title("foo bar");

my $link = XML::Atom::Syndication::Link->new(Version => 1.0);
   $link->href("http://www.example.com/");

my $entry = XML::Atom::Syndication::Entry->new(Version => 1.0);
   $entry->title("Foo Bar");

$feed->add_link($link);
$feed->add_entry($entry);

like $feed->as_xml, qr!<feed xmlns="http://www.w3.org/2005/Atom">!;




