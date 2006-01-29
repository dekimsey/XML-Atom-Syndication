#!perl

BEGIN { chdir 't' if -d 't' }

use strict;
use warnings;
use lib 'lib';

use Test::More tests => 19;

use XML::Atom::Syndication::Test::Util qw( get_feed );
use XML::Atom::Syndication::Feed;
use File::Spec;
use FileHandle;

my @rights = (
    ['feed_rights.xml','Example Atom'],
    ['feed_rights_escaped_markup.xml','Example <b>Atom</b>','html'],
    ['feed_rights_inline_markup_2.xml','<div>History of the &lt;blink&gt; tag</div>','xhtml'],
    ['feed_rights_inline_markup.xml','<div>Example <b>Atom</b></div>','xhtml'],
    ['feed_rights_text_plain.xml','Example Atom','text'],
    ['feed_rights_content_type_text.xml','Example Atom','text'],
    ['feed_rights_content_value.xml','Example Atom']
);

foreach my $r (@rights) {
    my $feed = get_feed($r->[0]);
    my $rights = $feed->rights;
    ok(ref $rights eq 'XML::Atom::Syndication::Text');
    ok($rights->body eq $r->[1]);    
    ok($rights->type eq $r->[2]) if $r->[2];
}

1;