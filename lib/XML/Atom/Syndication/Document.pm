# Copyright (c) 2004 Timothy Appnel
# http://www.timaoutloud.org/
# This code is released under the Artistic License.
#
# XML::Atom::Syndication::Document - a class representing the root
# of an Atom syndication feed.
# 

package XML::Atom::Syndication::Document;

use strict;

sub new { bless { }, $_[0]; }

sub contents { $_[0]->{contents} = $_[1] if defined $_[1]; $_[0]->{contents}; }
sub query { $_[0]->contents->[0]->query($_[1]) }

###--- hack to keep Class::XPath happy.
sub qname {}
sub _xpath_attribute {}
sub _xpath_attribute_names { () }

1;

__END__

=begin

=head1 NAME

XML::Atom::Syndication::Document - a class representing the root
of an Atom syndication feed.

=head1 DESCRIPTION

A ultra simple object that replaces the dynamic Document object
L<XML::Parser::Style::Elemental> used to provide us.

=head1 METHODS

=item XML::Atom::Syndication::Document->new

Constructor method. Creates an instance and returns it.

=item $atom->contents([\@children])

Returns an array reference to the documents's child objects in the
parse tree. Sets the value when an optional array reference
parameter is passed.

=item $atom->query($xpath)

Takes XPath-esque query string and, similar to the param method in
the L<CGI> pacakge, returns either the first item found or an array
of all matching elements depending on the context in which it is
called. C<undef> is returned if nothing could be matched. These
objects will be XML::Atom::Syndication elements except for the root
element, an instance of this class.

This is not a full XPath implementation. For more details on the
supported syntax see the documentation for L<Class::XPath>.

=head1 SEE ALSO

L<XML::Parser::Style::Elemental>, L<XML::Atom>, L<Class::XPath>

=head1 AUTHOR & COPYRIGHT

Please see the XML::Atom::Syndication manpage for author,
copyright, and license information.

=cut

=end

