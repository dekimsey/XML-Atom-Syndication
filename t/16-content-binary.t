# $Id$
use strict;
use Test::More tests => 1;

use Encode;
use XML::Atom::Syndication::Entry;

my $file = "t/samples/me.jpg";
my $data = slurp($file);

my $entry = XML::Atom::Syndication::Entry->new(Version=>0.3);
$entry->content($data);

ok( $data eq $entry->content->body );

sub slurp {
    my $file = shift;
    open my$fh, $file or die $!;
    local $/;
    <$fh>;
}



