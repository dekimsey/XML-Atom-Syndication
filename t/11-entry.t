# $Id$

use strict;

use Test;
use XML::Atom::Syndication;
use XML::Atom::Syndication::Entry;
use XML::Atom::Syndication::Person;

BEGIN { plan tests => 71 }

my $entry;

$entry = XML::Atom::Syndication::Entry->new;
$entry->title('Foo Bar');
ok($entry->title, 'Foo Bar');

$entry = XML::Atom::Syndication::Entry->new('t/samples/entry-ns.xml');
ok($entry);
ok($entry->title, 'Unit Test 1');

$entry = XML::Atom::Syndication::Entry->new(Stream => 't/samples/entry-ns.xml');
ok($entry->title, 'Unit Test 1');
my $body = $entry->content->body;
ok($body);
ok($body =~ m!^<img [^>]+>!); # modified because are serializer can't guarantee attribute order.
ok($body =~ /This is what you get when you do unit testing\./);

$entry = XML::Atom::Syndication::Entry->new(Stream => 't/samples/entry-full.xml');
ok($entry->title, 'Guest Author');
ok($entry->id, 'tag:typepad.com:post:75207');
ok($entry->issued, '2003-07-21T02:47:34-07:00');
ok($entry->modified, '2003-08-22T18:36:57-07:00');
ok($entry->created, '2003-07-21T02:47:34-07:00');
ok($entry->summary, 'No, Ben isn\'t updating. It\'s me testing out guest author functionality....');
ok($entry->author);
ok(ref($entry->author) eq 'XML::Atom::Syndication::Person');
ok($entry->author->name, 'Mena');
$entry->author->name('Ben');
ok($entry->author->url, 'http://mena.typepad.com/');
my $dc = XML::Atom::Syndication::Namespace->new(dc => 'http://purl.org/dc/elements/1.1/');
ok($entry->get($dc->subject), 'Food');
my @subj = $entry->get($dc->subject); # was $entry->getlist($dc->subject); but we aren't suporting getlist.
ok(@subj == 2);
ok($subj[0], 'Food');
ok($subj[1], 'Cats');
ok($entry->content);
ok($entry->content->body, '<p>No, Ben isn\'t updating. It\'s me testing out guest author functionality.</p>');

my @link = $entry->link;
ok(scalar @link, 2);
ok($link[0]->rel, 'alternate');
ok($link[0]->type, 'text/html');
ok($link[0]->href, 'http://ben.stupidfool.org/typepad/2003/07/guest_author.html');
ok($link[1]->rel, 'service.edit');
ok($link[1]->type, 'application/x.atom+xml');
ok($link[1]->href, 'http://www.example.com/atom/entry_id=75207');
ok($link[1]->title, 'Edit');

my $link = $entry->link;
ok(ref($link), 'XML::Atom::Syndication::Link');
ok($link->rel, 'alternate');
ok($link->type, 'text/html');
ok($link->href, 'http://ben.stupidfool.org/typepad/2003/07/guest_author.html');

$link = XML::Atom::Syndication::Link->new;
$link->title('Number Three');
$link->rel('service.post');
$link->href('http://www.example.com/atom');
$link->type('application/x.atom+xml');

$entry->add_link($link);
@link = $entry->link;
ok(scalar @link, 3);
ok($link[2]->rel, 'service.post');
ok($link[2]->type, 'application/x.atom+xml');
ok($link[2]->href, 'http://www.example.com/atom');
ok($link[2]->title, 'Number Three');

## xxx test setting/getting different content encodings
## xxx encodings
## xxx Doc param

$entry->title('Foo Bar');
ok($entry->title, 'Foo Bar');
$entry->set($dc->subject, 'Food & Drink');
ok($entry->get($dc->subject), 'Food & Drink');

ok(my $xml = $entry->as_xml);
my $entry2 = XML::Atom::Syndication::Entry->new(Stream => \$xml);
ok($entry2);
ok($entry2->title, 'Foo Bar');
ok($entry2->author->name, 'Ben');
ok($entry2->get($dc->subject), 'Food & Drink');
ok($entry2->content);
ok($entry2->content->body, '<p>No, Ben isn\'t updating. It\'s me testing out guest author functionality.</p>');

my $entry3 = XML::Atom::Syndication::Entry->new;
my $author = XML::Atom::Syndication::Person->new;
$author->name('Melody');
ok($author->name, 'Melody');
$author->email('melody@nelson.com');
$author->url('http://www.melodynelson.com/');
$entry3->title('Histoire');
ok(!$entry3->author);
$entry3->author($author);
ok($entry3->author);
ok($entry3->author->name, 'Melody');

$entry = XML::Atom::Syndication::Entry->new;
$entry->content('<p>Not well-formed.');
ok($entry->content->mode, 'escaped');
ok($entry->content->body, '<p>Not well-formed.');

$entry = XML::Atom::Syndication::Entry->new( Stream => \$entry->as_xml );
ok($entry->content->mode, 'escaped');
ok($entry->content->body, '<p>Not well-formed.');

$entry = XML::Atom::Syndication::Entry->new;
$entry->content("This is a test that should use base64\0.");
$entry->content->type('image/gif');
ok($entry->content->mode, 'base64');
ok($entry->content->body, "This is a test that should use base64\0.");
ok($entry->content->type, 'image/gif');

$entry = XML::Atom::Syndication::Entry->new( Stream => \$entry->as_xml );
ok($entry->content->mode, 'base64');
ok($entry->content->body, "This is a test that should use base64\0.");
ok($entry->content->type, 'image/gif');

my $ns = XML::Atom::Syndication::Namespace->new(list => "http://www.sixapart.com/atom/list#");
$link->set($ns, type => "Books");
$entry->add_link($link);
$xml = $entry->as_xml;
ok($xml =~ /__NS1:type="Books"/);

$entry->set($dc, "subject" => "Weblog");
ok($entry->as_xml =~ m!<dc:subject .*>Weblog</dc:subject>!); # added dc: to all of these because that is the way XML::Writer handles it without an explicit declaration

$entry->add($dc, "subject" => "Tech");
ok($entry->as_xml =~ m!<dc:subject .*>Weblog</dc:subject>!);
ok($entry->as_xml =~ m!<dc:subject .*>Tech</dc:subject>!);

# re-set
$entry->set($dc, "subject" => "Weblog");
ok($entry->as_xml =~ m!<dc:subject .*>Weblog</dc:subject>!);
ok($entry->as_xml !~ m!<dc:subject .*>Tech</dc:subject>!);

# euc-jp feed
$entry = XML::Atom::Syndication::Entry->new('t/samples/entry-euc.xml');
ok $entry->title, 'ゲストオーサー';
ok $entry->content->body, '<p>日本語のフィード</p>';
