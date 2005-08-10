# Copyright (c) 2004-2005 Timothy Appnel
# http://www.timaoutloud.org/
# This code is released under the Artistic License.
#
# XML::Atom::Syndication::Element - a class representing a tag
# element in an Atom syndication feed with an XPath-esque interface.
#

package XML::Atom::Syndication::Element;

use strict;
use Class::XPath 1.4
  get_name     => 'qname',
  get_parent   => 'parent',
  get_root     => '_xpath_root',
  get_children => sub {
    return () unless $_[0]->can('contents');
    @{$_[0]->contents || []};
  },
  get_attr_names => '_xpath_attribute_names',
  get_attr_value => '_xpath_attribute',
  get_content    => 'text_value';

sub new { bless {}, $_[0]; }

sub name     { $_[0]->{name}     = $_[1] if defined $_[1]; $_[0]->{name}; }
sub parent   { $_[0]->{parent}   = $_[1] if defined $_[1]; $_[0]->{parent}; }
sub contents { $_[0]->{contents} = $_[1] if defined $_[1]; $_[0]->{contents}; }
sub attributes { $_[0]->{attr} = $_[1] if defined $_[1]; $_[0]->{attr}; }

sub text_value {
    return '' unless ref($_[0]->contents);
    join('',
         map { ref($_) eq __PACKAGE__ ? $_->text_value : $_->data }
           @{$_[0]->contents});
}

###--- XPath routines

sub query {
    my @nodes = $_[0]->match($_[1]);
    wantarray ? @nodes : $nodes[0];
}

sub qname {
    my $extname = $_[1] ? $_[1] : ref($_[0]) ? $_[0]->{name} : $_[0];
    my ($ns, $local) = $extname =~ m!^(.*?)([^/#]+)$!;
    my $prefix = XML::Atom::Syndication->xpath_namespace($ns);
    unless ($prefix) {   # perhaps slash needs to vanish? # in for good measure.
        $ns =~ s{[/#]$}{};
        $prefix = XML::Atom::Syndication->xpath_namespace($ns);
    }
    # die "Undefined XPath namespace prefix for $ns" unless $prefix;
    unless ($prefix) {    # make a generic one.
        my $i = 1;
        while (XML::Atom::Syndication->xpath_namespace("NS$i")) { $i++ }
        XML::Atom::Syndication->xpath_namespace("NS$i", $ns);
        $prefix = "NS$i";
    }
    $prefix ne '#default' ? "$prefix:$local" : $local;
}

sub _xpath_attribute_names {
    return () unless $_[0]->{attr};
    map { qname($_) } keys %{$_[0]->{attr}};
}

sub _xpath_attribute {
    my $self = shift;
    my $name = shift;
    my $ns   = '';
    if ($name =~ /(\w+):(\w+)/) {
        $name = $2;
        $ns   = XML::Atom::Syndication->xpath_namespace($1);
        $ns .= '/' unless $ns =~ m![/#]$!;
    } else {
        ($ns = $self->name) =~ s/\w+$//;
    }
    $self->{attr}->{"$ns$name"};
}

sub _xpath_root {
    my $o = shift;
    while ($o->can('parent') && $o->parent) { $o = $o->parent }
    $o;
}

1;

__END__

=begin

=head1 NAME

XML::Atom::Syndication::Element - a class representing a tag
element in an Atom syndication feed with an XPath-esque interface.

=head1 DESCRIPTION

This module is a simple class for representing a tag element in an
Atom syndication feed parse tree that implements an XPath-esque
interface for query the tree of elements and retreiving data.

=head1 METHODS

=item XML::Atom::Syndication::Element->new

Constructor method. Creates an instance and returns it.

=item $atom->name([$name])

Returns the extended name (Namespace URI and tag name) of the
element. Sets the value when an optional parameter is passed.

=item $atom->qname([$extend_name])

Returns the qualified name (QName) according to the XPath namespace
prefixes. Takes an optional extended name parameter to resolve, Returns the
QName of the current element otherwise.

=item $atom->parent([$element])

Returns a reference to the element's parent object in the parse
tree. Sets the value when an optional parameter is passed.

=item $atom->contents([\@children])

Returns an array reference to the element's child objects in the
parse tree. Sets the value when an optional array reference
parameter is passed.

=item $atom->attributes([\%attr])

Returns a hash reference of the element's attributes. Sets the
value when an optional hash reference parameter is passed.

=item $atom->text_value

This method returns all of the sibling character data (read: the
text and whitespace between this element's start and end tag with
the tags stripped) as a single string.

=item $atom->query($xpath)

Takes XPath-esque query string and, similar to the param method in
the L<CGI> pacakge, returns either the first item found or an array
of all matching elements depending on the context in which it is
called. C<undef> is returned if nothing could be matched. These
objects will be of this class except for the root element which
will be a L<XML::Atom::Syndication::Document> object.

This is not a full XPath implementation. For more details on the
supported syntax see the documentation for L<Class::XPath>.

=item $atom->xpath

Returns a unique XPath identifier string for the element.

=head1 SEE ALSO

L<XML::Parser::Style::Elemental>, L<XML::Atom>, L<Class::XPath>

=head1 AUTHOR & COPYRIGHT

Please see the XML::Atom::Syndication manpage for author,
copyright, and license information.

=cut

=end

