package XML::Atom::Syndication::Feed;
use strict;

use base qw( XML::Atom::Syndication::Thing );

use XML::Atom::Syndication::Util qw( nodelist );

sub version { $_[0]->{version} }

sub element_name { 'feed' }

sub language {
    my $feed = shift;
    my $name = '{http://www.w3.org/XML/1998/namespace}lang';
    $feed->elem->attributes->{$name} = $_[0] if @_;
    $feed->elem->attributes->{$name};
}

sub add_entry {
    my $feed = shift;
    my ($entry, $opt) = @_;
    $opt ||= {};
    $entry = $entry->elem if ref $entry eq 'XML::Atom::Syndication::Entry';

    # If Insert mode is specified we find the first entry element
    # and insert before that element to avoid messing up any preamble.
    # If there no entries we fallback to doing an append.
    my ($first) = nodelist($feed, $feed->ns, 'entry');
    if ($opt->{mode} && $opt->{mode} eq 'insert' && $first) {
        my @new =
          map { $_ eq $first ? ($entry, $_) : $_ } @{$feed->elem->contents};
        $feed->elem->contents(\@new);
    } else {
        $feed->add($feed->ns, 'entry', $entry, undef, 1);
    }
}

sub insert_entry { shift->add_entry(shift, {mode => 'insert'}) }

sub entries {
    my $feed = shift;
    my @nodes = nodelist($feed, $feed->ns, 'entry');
    return unless @nodes;
    my @entries;
    require XML::Atom::Syndication::Entry;
    foreach my $node (@nodes) {
        my $entry =
          XML::Atom::Syndication::Entry->new(Elem      => $node,
                                             Namespace => $feed->ns);
        push @entries, $entry;
    }
    @entries;
}

1;

__END__

=begin

=head1 NAME

XML::Atom::Syndication::Feed - class representing an Atom feed

=head1 DESCRIPTION

=head1 METHODS

L<XML::Atom::Syndication::Feed> is a subclass of
L<XML::Atom::Syndication:::Thing> that it inherits numerous
methods from in addition to implementing some of its own.
You should already be familar with those that class and its
base class L<XML::Atom::Syndication::Object> before
proceeding.

The methods specific to this class are as follows:

=over

=item language

Accessor to the C<xml:lang> attribute. See
[W3C.REC-xml-20040204], Section 2.12 for more on the use of
this attribute.

=item $feed->generator_uri($uri)

=item $feed->generator_version($version)

=item $feed->add_entry($entry)

Appends a L<XML::Atom::Syndication::Entry> object to the
feed. The new entry is placed at the end of all other
entries.

=item $feed->insert_entry($entry)

Inserts a L<XML::Atom::Syndication::Entry> object I<before>
all other entries in the feed.

=item $feed->entries

Returns an ordered ARRAY of L<XML::Atom::Syndication::Entry> objects 
representing the feed's entries.

=back

=head2 ELEMENT ACCESSORS

The following known Atom elements can be accessed through
objects of this class. See ELEMENT ACCESSORS in
L<XML::Atom::Syndication::Object> for more detail.

=over 

=item generator

Identifies the agent used to generate a feed for debugging
and other purposes. See the section below on accessing the 
generator URI and version.

=item icon

An IRI reference [RFC3987] which identifies an image which
provides iconic visual identification for a feed.

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

=item subtitle

Conveys a human-readable description or subtitle of a feed.

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

=head2 ACCESSING THE GENERATOR URI AND VERSION

The generator element is currently implemented as a standard
element accessor. This is fin if all you want is the
human-readable label however the uri and version attributes
that may be present cannot be accessed through this means.
If you do need access to these attributes use the node_list
utility method to retreive the underlying generator element
and then get/set the attribute. For instance...

 my($g) = nodelist($feed,$feed->ns,'generator');
 $g->attributes->{uri};                 # get uri attribute
 $g->attributes->{version} = '1.0';     # set version attribute

=head1 AUTHOR & COPYRIGHT

Please see the XML::Atom::Syndication manpage for author,
copyright, and license information.

=cut

=end
