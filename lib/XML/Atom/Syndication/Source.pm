package XML::Atom::Syndication::Source;
use strict;

use base qw( XML::Atom::Syndication::Thing );

sub element_name { 'source' }

# This is the init method in XML::Atom::Syndication::Object. Could do
# better.

sub init {
    my $atom = shift;
    my %param = @_ == 1 ? (Elem => $_[0]) : @_;
    $atom->set_ns(\%param);
    unless ($atom->{elem} = $param{Elem}) {
        require XML::Elemental::Element;
        $atom->{elem} = XML::Elemental::Element->new;
        $atom->{elem}->name('{' . $atom->ns . '}' . $atom->element_name);
    }
    $atom;
}

1;

__END__

=begin

=head1 NAME

XML::Atom::Syndication::Source - class representing an Atom
source element

=head1 DESCRIPTION

If an atom:entry is copied from one feed into another feed,
then the source atom:feed's metadata (all child elements of
atom:feed other than the atom:entry elements) MAY be
preserved within the copied entry by adding an atom:source
child element, if it is not already present in the entry,
and including some or all of the source feed's Metadata
elements as the atom:source element's children. Such
metadata SHOULD be preserved if the source atom:feed
contains any of the child elements atom:author,
atom:contributor, atom:rights, or atom:category and those
child elements are not present in the source atom:entry.

The atom:source element is designed to allow the aggregation
of entries from different feeds while retaining information
about an entry's source feed. For this reason, Atom
Processors which are performing such aggregation SHOULD
include at least the required feed-level Metadata elements
(atom:id, atom:title, and atom:updated) in the atom:source
element.

Essentially the source element contains any or all of the
elements that can be found in a feed element except for
atom:published and atom entry elements.

=head1 METHODS

XML::Atom::Syndication::Source is a subclass of
L<XML::Atom::Syndication:::Thing> that it inherits numerous
methods from. You should already be familar with its base
class before proceeding.

=head2 STREAM NOT SUPPORTED IN NEW

The source element is not to be the root of a document like
the feed element therefore the Stream parameter is
purposfully ignored if passed in with the C<new> method.

=head2 ELEMENT ACCESSORS

The following known Atom elements can be accessed through
objects of this class. See ELEMENT ACCESSORS in
L<XML::Atom::Syndication::Object> for more detail.

XML::Atom::Syndication::Source supports the same element
accesors as L<XML::Atom::Syndication::Feed> except for
atom:published.

=head1 AUTHOR & COPYRIGHT

Please see the XML::Atom::Syndication manpage for author,
copyright, and license information.

=cut

=end
