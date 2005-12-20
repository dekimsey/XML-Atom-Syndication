package XML::Atom::Syndication::Entry;
use strict;

use base qw( XML::Atom::Syndication::Thing );

use XML::Atom::Syndication::Content;

sub element_name { 'entry' }

sub content {
    my $entry = shift;
    my @arg   = @_;
    if (@arg && !ref($arg[0]) ne 'XML::Atom::Syndication::Content') {
        $arg[0] =
          XML::Atom::Syndication::Content->new(Body      => $arg[0],
                                               Namespace => $entry->ns);
    }
    $entry->_element('XML::Atom::Syndication::Content', 'content', @arg);
}

1;

__END__

=begin

=head1 NAME

XML::Atom::Syndication::Entry - class representing an Atom entry

=head1 DESCRIPTION

=head1 METHODS

L<XML::Atom::Syndication::Entry> is a subclass of
L<XML::Atom::Syndication:::Thing> that it inherits numerous
methods from in addition to implementing some of its own.
You should already be familar with those that class and its
base class L<XML::Atom::Syndication::Object> before
proceeding.

The methods specific to this class are as follows:

=over

=item $entry->content($body)

Contains or links to the content of the entry. C<$body> must
be a string or L<XML::Atom::Syndication::Content> object.

B<NOTE: Content handling is currently not Atom 1.0 compliant.>

=back

=head2 ELEMENT ACCESSORS

The following known Atom elements can be accessed through
objects of this class. See ELEMENT ACCESSORS in
L<XML::Atom::Syndication::Object> for more detail.

=over 

=item id

A permanent, universally unique identifier for an entry or
feed.

=item published

A date indicating an instance in time associated with an
event early in the life of the entry. Dates values MUST
conform to the "date-time" production in [RFC3339].

=item rights

Conveys information about rights held in and over an entry
or feed.

=item summary

Conveys a short summary, abstract, or excerpt of an entry.

=item title

Conveys a human-readable title for an entry or feed.

=item updated

The most recent instance in time when an entry or feed was
modified in a way the publisher considers significant. Dates
values MUST conform to the "date-time" production in
[RFC3339].

=back

=head1 AUTHOR & COPYRIGHT

Please see the XML::Atom::Syndication manpage for author,
copyright, and license information.

=cut

=end