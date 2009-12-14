# $Id$

use strict;

use Test;
use XML::Atom::Syndication::Feed;
use URI;

BEGIN { plan tests => 32 };

my $feed;

$feed = XML::Atom::Syndication::Feed->new(Stream=>'t/samples/feed.xml', Version=>0.3);
ok($feed->title, 'dive into atom');
ok(ref($feed->link), 'XML::Atom::Syndication::Link');
ok($feed->link->href, 'http://diveintomark.org/atom/');
ok(1); # $feed->version, '0.2'); # we don't support this option.
ok($feed->language, 'en');
ok($feed->modified, '2003-08-25T11:39:42Z');
ok($feed->tagline, '');
ok($feed->id, 'tag:diveintomark.org,2003:14');
ok($feed->generator, 'http://www.movabletype.org/?v=2.64');
ok($feed->copyright, 'Copyright (c) 2003, Atom User');

ok($feed->author);
ok($feed->author->name, 'Atom User');
ok($feed->author->email, 'atom@example.com');
ok($feed->author->homepage, 'http://diveintomark.org/atom/');

# $feed->version('0.3');
ok(1);  #ok($feed->version, '0.3');
$feed->language('fr');
ok($feed->language, 'fr');

my @entries = $feed->entries;
ok(scalar @entries, 15);
my $entry = $entries[0];
ok(ref($entry), 'XML::Atom::Syndication::Entry');
ok($entry->title, 'Test');
ok($entry->content->body, '<p>Python is cool stuff for ReSTy webapps.</p>');

$entry = XML::Atom::Syndication::Entry->new(Version=>0.3);
$entry->title('Foo');
$entry->content('<p>This is a test.</p>');
$feed->add_entry($entry);

@entries = $feed->entries;
ok(scalar @entries, 16);
my $last = $entries[-1];
ok($last->title, 'Foo');
ok($last->content->body, '<p>This is a test.</p>');

$feed->add_link({ title => 'Number Three', rel => 'service.post',
                  href => 'http://www.example.com/atom',
                  type => 'application/x.atom+xml' });
my @links = $feed->link;
ok(scalar @links, 2);
ok(ref($links[-1]), 'XML::Atom::Syndication::Link');
ok($links[-1]->title, 'Number Three');
ok($links[-1]->rel, 'service.post');
ok($links[-1]->href, 'http://www.example.com/atom');
ok($links[-1]->type, 'application/x.atom+xml');

# Test we can insert an entry in the front.
$entry = XML::Atom::Syndication::Entry->new(Version=>0.3);
$entry->title('Bar');
$entry->content('<p>This is another test.</p>');
$feed->add_entry($entry, { mode => 'insert' });
@entries = $feed->entries;

ok(scalar @entries, 17);
ok($entries[0]->title, 'Bar');
ok( $feed->title, 'dive into atom' );
