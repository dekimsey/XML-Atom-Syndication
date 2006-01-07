package XML::Atom::Syndication::Person;
use strict;
use base qw( XML::Atom::Syndication::Object );

1;

__END__

=begin

=head1 NAME

XML::Atom::Syndication::Person - class representing an Atom
person construct

=head1 DESCRIPTION

A Person construct is an element that describes a person,
corporation, or similar entity. The person construct is used
to define an author or contributor.

=head1 METHODS

XML::Atom::Syndication::Person is a subclass of
L<XML::Atom::Syndication:::Object> that it inherits numerous
methods from. You should already be familar with its base
class before proceeding.

=over

=item XML::Atom::Syndication::Author->new(...)

=item XML::Atom::Syndication::Contributor->new(...)

Since a person construct can be an author or a contributor
XML::Atom::Syndication::Person contains two subclasses,
XML::Atom::Syndication::Author and
XML::Atom::Syndication::Contributor. These classes have
identical interfaces. The only difference is the underlying
element they represent in the parse tree.

=back

=head2 ELEMENT ACCESSORS

The following known Atom elements can be accessed through
objects of these classes. See ELEMENT ACCESSORS in
L<XML::Atom::Syndication::Object> for more detail.

=over 

=item name

A human-readable name for the person. A person construct
must contain one name element.

=item uri

An IRI associated with the person.

=item email

An e-mail address associated with the person.

=back

=head1 AUTHOR & COPYRIGHT

Please see the XML::Atom::Syndication manpage for author,
copyright, and license information.

=cut

=end
