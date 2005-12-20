# $Id$
use strict;
use Test::More tests => 2;

use Encode;
use XML::Atom::Syndication::Entry;

my $file = "t/samples/lifeblog-atom.xml";
my $xml  = slurp($file);

my $entry = XML::Atom::Syndication::Entry->new(Stream => \$xml, Version=>0.3);

ok $entry;
ok !Encode::is_utf8($entry->content->body);

sub slurp {
    my $file = shift;
    open my$fh, $file or die $!;
    local $/;
    <$fh>;
}



