# Copyright (c) 2004 Timothy Appnel
# http://www.timaoutloud.org/
# This code is released under the Artistic License.
#
# XML::Atom::Syndication::Characters - a class representing character
# data in an Atom syndication feed.
# 

package XML::Atom::Syndication::Characters;

use strict;

sub new { bless { }, $_[0]; }

sub parent { $_[0]->{parent} = $_[1] if defined $_[1]; $_[0]->{parent}; }
sub data { $_[0]->{data} = $_[1] if defined $_[1]; $_[0]->{data}; }

###--- hack to keep Class::XPath happy.
sub _xpath_name {}
sub _xpath_attribute {}
sub _xpath_attribute_names { () }

1;

__END__

=begin

=head1 NAME

XML::Atom::Syndication::Characters - a class representing character 
data in an Atom syndication feed.

=head1 DESCRIPTION

A ultra simple object that replaces the dynamic Characters object
L<XML::Parser::Style::Elemental> used to provide us.

=head1 METHODS

=item XML::Atom::Syndication::Characters->new

Constructor method. Creates an instance and returns it.

=item $atom->data([$string])

Returns the character data of the element. Sets the value when an
optional parameter is passed.

=item $atom->parent([$element])

Returns a reference to the element's parent object in the parse
tree. Sets the value when an optional parameter is passed.

=head1 SEE ALSO

L<XML::Parser::Style::Elemental>, L<XML::Atom>, L<Class::XPath>

=head1 AUTHOR & COPYRIGHT

Please see the XML::Atom::Syndication manpage for author,
copyright, and license information.

=cut

=end

