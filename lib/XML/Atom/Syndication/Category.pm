package XML::Atom::Syndication::Category;
use strict;

use base qw( XML::Atom::Syndication::Object );

sub element_name { 'category' }

sub get { shift->get_attribute(@_) }
sub set { shift->set_attribute(@_) }

1;

__END__

=begin

=head1 NAME

XML::Atom::Syndication::Category - class representing an Atom category

=head1 DESCRIPTION

Conveys information about a category associated with an
entry or feed. This specification assigns no meaning to the
content (if any) of this element.

=head1 METHODS

XML::Atom::Syndication::Category is a subclass of
L<XML::Atom::Syndication:::Object> that it inherits numerous
methods from. You should already be familar with its base
class before proceeding.

=head2 ELEMENT ACCESSORS

The following known Atom elements can be accessed through
objects of this class. See ELEMENT ACCESSORS in
L<XML::Atom::Syndication::Object> for more detail.

=over 

=item term

A string that identifies the category to which the entry or
feed belongs. This attribute is requires of all category
elements.

=item scheme

An IRI that identifies a categorization scheme.

=item label

A human-readable label for display in end-user applications.

=back

=head1 AUTHOR & COPYRIGHT

Please see the XML::Atom::Syndication manpage for author,
copyright, and license information.

=cut

=end
