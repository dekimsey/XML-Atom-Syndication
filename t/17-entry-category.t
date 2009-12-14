#!perl

BEGIN { chdir 't' if -d 't' }

use strict;
use warnings;
use lib 'lib';

use Test::More tests => 6;

use XML::Atom::Syndication::Test::Util qw( get_feed );
use XML::Atom::Syndication::Feed;
use File::Spec;
use FileHandle;

my @cats = (
    ['entry_category_label.xml','label','Atom 1.0 tests'],
    ['entry_category_scheme.xml','scheme','http://feedparser.org/tests/'],
    ['entry_category_term.xml','term','atom10']
);

foreach my $c (@cats) {
    my $feed = get_feed($c->[0]);
    my @e = $feed->entries;
    my $cat = $e[0]->category;
    ok(ref $cat eq 'XML::Atom::Syndication::Category');
    my $meth = $c->[1];
    ok($cat->$meth eq $c->[2]);
}

__END__
my $feed = get_feed('entry_category_multiple.xml');
my @e = $feed->entries;
my @cats2 = $e[0]->category;
ok(@cats2 == 2);
ok(ref $cats2[0] eq 'XML::Atom::Syndication::Category');
ok($cats2[0]->name eq '');
ok($cats2[1]->name eq '');

1;