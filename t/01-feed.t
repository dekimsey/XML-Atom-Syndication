#!perl

BEGIN { chdir 't' if -d 't' }

use strict;
use warnings;
use lib 'lib';

use Test::More tests => 8;

use XML::Atom::Syndication::Test::Util qw( get_feed );
use XML::Atom::Syndication::Feed;
use File::Spec;

my $feed = XML::Atom::Syndication::Feed->new;
ok(ref $feed eq 'XML::Atom::Syndication::Feed');

my $feed1 = get_feed('feed_icon.xml');
ok($feed1->icon eq 'http://example.com/favicon.ico');

my $feed2 = get_feed('feed_id.xml');
ok($feed2->id eq 'http://example.com/');

my $feed3 = get_feed('feed_logo.xml');
ok($feed3->logo eq 'http://example.com/logo.jpg');

# need updated test here.
#    my $feed4 = get_feed(File::Spec->catfile('x','feed_icon.xml'));
#    ok($feed4->updated eq '');

my $feed5 = get_feed('feed_generator.xml');
my $g = $feed5->generator;
ok(ref $g eq 'XML::Atom::Syndication::Generator');
ok($g->agent eq 'Example generator');
ok($g->version eq '2.65');
ok($g->uri eq 'http://example.com/');

# entries 
# right type?
# count?

# add entry
# entries

# insert entry
# entries

# remove entry
# check count

1;