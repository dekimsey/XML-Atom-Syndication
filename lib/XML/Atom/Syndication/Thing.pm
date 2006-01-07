package XML::Atom::Syndication::Thing;
use strict;

use base qw( XML::Atom::Syndication::Object );

use XML::Atom::Syndication::Util qw( nodelist );

sub init {
    my $thing = shift;
    my %param = @_ == 1 ? (Stream => $_[0]) : @_;
    $thing->set_ns(\%param);
    if (%param) {
        if (my $stream = $param{Stream}) {
            my $parser = XML::Elemental->parser;
            if (ref($stream) eq 'SCALAR') {
                $thing->{doc} = $parser->parse_string($$stream);
            } elsif (ref $stream eq 'GLOB' || !ref($stream)) {
                $thing->{doc} = $parser->parse_file($stream);
            } else {
                return;
            }
            $thing->{elem} = $thing->{doc}->contents->[0];
        } elsif ($param{Elem}) {
            $thing->{elem} = $param{Elem};
        }
    } else {
        require XML::Elemental::Element;
        $thing->{elem} = XML::Elemental::Element->new;
        $thing->{elem}->name('{' . $thing->ns . '}' . $thing->element_name);
    }
    $thing;
}

sub author {
    my $thing = shift;
    require XML::Atom::Syndication::Person;
    $thing->_element('XML::Atom::Syndication::Author', 'author', @_);
}

sub contributor {
    my $thing = shift;
    require XML::Atom::Syndication::Person;
    $thing->_element('XML::Atom::Syndication::Contributor', 'contributor', @_);
}

sub category {
    my $thing = shift;
    $thing->_element('XML::Atom::Syndication::Category', 'category', @_);
}

sub add_link {
    my $thing = shift;
    my ($link) = @_;
    my $elem;
    if (ref $link eq 'XML::Atom::Syndication::Link') {
        $elem = $link->elem;
    } else {
        $elem = XML::Elemental::Element->new;
        $elem->name('{' . $thing->ns . '}link');
        if (ref $link eq 'HASH') {    # diff from XML::Atom
            my %link;
            map { $link{"{}$_"} = $link->{$_} } keys %$link;
            $elem->attributes(\%link);
        }
    }
    $elem->parent($thing->elem);
    push @{$thing->elem->contents}, $elem;
}

sub link {
    my $thing = shift;
    my @nodes = nodelist($thing, $thing->ns, 'link');
    return unless @nodes;
    my @links;
    require XML::Atom::Syndication::Link;
    foreach my $node (@nodes) {
        my $link =
          XML::Atom::Syndication::Link->new(Elem      => $node,
                                            Namespace => $thing->ns);
        push @links, $link;
    }
    wantarray ? @links : $links[0];
}

sub _element {   # combined get/set for known object accessors in atom namespace
    my $atom = shift;
    my ($class, $name) = (shift, shift);
    if (@_) {
        my $add = 0;
        map { $atom->set($atom->ns, $name, $_, undef, $add++) } @_;
    } else {
        my @elem = nodelist($atom, $atom->ns, $name);
        return unless @elem;
        eval "require $class";
        my @parts =
          map { $class->new(Elem => $_, Namespace => $atom->ns) } @elem;
        wantarray ? @parts : $parts[0];
    }
}

1;

__END__

=begin

=head1 NAME

XML::Atom::Syndication::Thing - base class for the feed and entry class

=head1 METHODS

This module is a subclass of
L<XML::Atom::Syndication::Object>.the following additional
methods are available.

=over

=item Class->new($HASHREF)

In addition to the keys recognized by its superclass this class recognizes:

=over 8

=item Stream 

A SCALAR or FILEHANDLE (GLOB) to a valid Atom document. Stream takes 
presidence over Elem.

=back

=item $thing->author([$author,$author...])

=item $thing->contributor([$contributor,$contributor...])

=item $thing->category([$category,$category...])

These three accessors methods have similar purposes for
accessing known complex Atom object types. You can
optionally pass in one of more Atom objects that will
overwrite any existing elements. C<author> and
C<contributor> expect a L<XML::Atom::Syndication::Person>
object while C<category> expects a
L<XML::Atom::Syndication::Category> object. The method returns 
the first object if called in a SCALAR context and all elements 
if called in an ARRAY context.

=item $thing->add_link($link)

Creates a new link element. C<$link> can be a
L<XML::Atom::Syndication::Link> object or a HASH reference.
The HASH reference contains key value pairs that will be
assigned the new link object as attributes. Keys must
include namespace URIs and local name in Clarkian notation.

=item $thing->link

If called in a SCALAR context returns the first
L<XML::Atom::Syndication::Link>. In an ARRAY context all
link objects will be returned.

=back

=head1 AUTHOR & COPYRIGHT

Please see the XML::Atom::Syndication manpage for author,
copyright, and license information.

=cut

=end
