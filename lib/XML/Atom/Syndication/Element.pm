# Copyright (c) 2004 Timothy Appnel
# http://www.timaoutloud.org/
# This code is released under the Artistic License.
#
# XML::Atom::Syndication::Element - a class representing a tag
# element in an Atom syndication feed with an XPath-esque interface.
# 

package XML::Atom::Syndication::Element;

use strict;
use Class::XPath 1.4
     get_name => '_xpath_name',
     get_parent => 'parent',
     get_root => '_xpath_root',
     get_children => sub { 
                return () unless $_[0]->can('contents'); 
                @{ $_[0]->contents || [] } 
            },
     get_attr_names => '_xpath_attribute_names',
     get_attr_value => '_xpath_attribute',
     get_content => 'text_value',
     call_match => 'query';

sub new { bless { }, $_[0]; }

sub name { $_[0]->{name} = $_[1] if defined $_[1]; $_[0]->{name}; }
sub parent { $_[0]->{parent} = $_[1] if defined $_[1]; $_[0]->{parent}; }
sub contents { $_[0]->{contents} = $_[1] if defined $_[1]; $_[0]->{contents}; }
sub attributes { $_[0]->{attr} = $_[1] if defined $_[1]; $_[0]->{attr}; }

sub text_value {
    return '' unless ref($_[0]->contents);
    join('', map { ref($_) eq __PACKAGE__ ? 
                $_->text_value : $_->data } 
                    @{ $_[0]->contents } );
}

###--- XPath routines

my %xpath_prefix = (
    '#default'=>"http://purl.org/atom/ns#",
    dc=>"http://purl.org/dc/elements/1.1/",
    dcterms=>"http://purl.org/dc/terms/",
    sy=>"http://purl.org/rss/1.0/modules/syndication/",
    trackback=>"http://madskills.com/public/xml/rss/module/trackback/",
    xhtml=>"http://www.w3.org/1999/xhtml/",
    xml=>"http://www.w3.org/XML/1998/namespace/"
);
my %xpath_ns = reverse %xpath_prefix;

sub _xpath_name {
    my $in = ref($_[0]) ? $_[0]->{name} : $_[0] ;
    my($ns,$name) = $in =~m!^(.*?)([^/#]+)$!;
    my $prefix =  $xpath_ns{$ns} || '';
    # doubtful that this is how an undefined xpath namespace 
    # should be handled.
    $prefix && $prefix ne '#default' ? "$prefix:$name" : $name;
}

sub _xpath_attribute_names { 
	return () unless $_[0]->{attr};
    map { _xpath_name($_) } keys %{ $_[0]->{attr} };
}

sub _xpath_attribute {
	my $self = shift;
	my $name = shift;
	my $ns = '';
	if ( $name=~/(\w+):(\w+)/ ) {
		$name = $2;
		$ns = $xpath_prefix{$1};
		$ns .=  '/' unless $ns=~m![/#]$!;
	} else {
	    ($ns = $self->name)=~ s/\w+$//;
	}
	$self->{attr}->{"$ns$name"};
}

sub _xpath_root { 
    my $o=shift; 
    while($o->can('parent') && $o->parent) { $o = $o->parent }
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

L<XML::Parser::Style::Elemental> dynamically constructs the
extremely rudimentary XML::Atom::Syndication::Document and
XML::Atom::Syndication::Characters packages. The Element object is
marginally more sophisticated and required something a bit more
specific to implement and manage the XPath interface and underlying
functions.

=head1 METHODS

=item XML::Atom::Syndication::Element->new

Constructor method. Creates an instance and returns it.

=item $atom->name([$name])

Returns the extended name (Namespace URI and tag name) of the
element. Sets the value when an optional parameter is passed.

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

Take XPath-esque query string and returns an array of matching
elements or C<undef> if nothing could be matched. These objects
will be XML::Atom::Syndication elements except for the root element
which will be a (dynamically generated)
XML::Atom::Syndication::Document object.

This is not a full XPath implementation. For more details on the
supported syntax see the documentation for L<Class::XPath>.

=item $atom->xpath

Returns a unique XPath identifier string for the element.

=head1 SEE ALSO

L<XML::Parser::Style::Elemental>, L<XML::Atom>, L<Class::XPath>

=head1 LICENSE

The software is released under the Artistic License. The terms of
the Artistic License are described at
L<http://www.perl.com/language/misc/Artistic.html>.

=head1 AUTHOR & COPYRIGHT

Except where otherwise noted, XML::Atom::Syndication::Element is
Copyright 2004, Timothy Appnel, cpan@timaoutloud.org. All rights
reserved.

=cut

=end

