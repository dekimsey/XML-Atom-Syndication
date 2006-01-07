package XML::Atom::Syndication::Object;
use strict;

use base qw( Class::ErrorHandler );

use XML::Elemental;
use XML::Atom::Syndication::Util qw( nodelist utf8_off );
use XML::Atom::Syndication::Writer;

sub new {
    my $class = shift;
    my $atom = bless {}, $class;
    $atom->init(@_) or return $class->error($atom->errstr);
    $atom;
}

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

sub ns           { $_[0]->{ns} }
sub elem         { $_[0]->{elem} }
sub element_name { die 'element_name must be overwritten.' }

sub get_element {
    my $atom = shift;
    my ($ns, $name) = @_;
    my $ns_uri =
      ref($ns) eq 'XML::Atom::Syndication::Namespace' ? $ns->{uri} : $ns;
    my @nodes = nodelist($atom, $ns_uri, $name);
    return unless @nodes;
    my @vals = map { utf8_off($_->text_content) } @nodes;
    wantarray ? @vals : $vals[0];
}

sub set_element {
    my $atom = shift;
    my ($ns, $name, $val, $attr, $add) = @_;
    my $ns_uri =
      ref($ns) eq 'XML::Atom::Syndication::Namespace' ? $ns->{uri} : $ns;
    unless ($add) {
        my @nodes = nodelist($atom, $ns_uri, $name);
        foreach my $node (@nodes) {
            _remove($node) || return $atom->error($node->errstr);
        }
    }
    if (my $class = ref $val) {
        $val = $val->elem if $class =~ /^XML::Atom::Syndication::/;
        $val->parent($atom->elem);
        push @{$atom->elem->contents}, $val;
    } elsif (defined $val) {
        my $elem = XML::Elemental::Element->new;
        $elem->name("{$ns_uri}$name");
        $elem->attributes($attr) if $attr;
        $elem->parent($atom->elem);
        push @{$atom->elem->contents}, $elem;
        use XML::Elemental::Characters;
        my $chars = XML::Elemental::Characters->new;
        $chars->data($val);
        $chars->parent($elem);
        push @{$elem->contents}, $chars;
    }
    $val;
}

sub get_attribute {
    my $atom = shift;
    my ($val);
    if (@_ == 1) {
        my ($attr) = @_;
        $val = $atom->{elem}->attributes->{"{}$attr"};
    } elsif (@_ == 2) {
        my ($ns, $attr) = @_;
        $ns = '' if $atom->ns eq $ns;
        $val = $atom->{elem}->attributes->{"{$ns}$attr"};
    }
    utf8_off($val);
}

sub set_attribute {
    my $atom = shift;
    if (@_ == 2) {
        my ($attr, $val) = @_;
        $atom->{elem}->attributes->{"{}$attr"} = $val;
    } elsif (@_ == 3) {
        my ($ns, $attr, $val) = @_;
        my $ns_uri =
          ref($ns) eq 'XML::Atom::Syndication::Namespace' ? $ns->{uri} : $ns;
        $ns_uri = '' if $atom->ns eq $ns_uri;
        $atom->{elem}->attributes->{"{$ns_uri}$attr"} = $val;
    }
}

sub get { shift->get_element(@_) }
sub set { shift->set_element(@_) }

sub add {
    my $atom = shift;
    my ($ns, $name, $val, $attr, $add) = @_;
    $atom->set_element($ns, $name, $val, $attr, 1);
}

sub remove {
    my $atom = shift;
    _remove($atom->elem, @_);
}

sub _remove {
    my $elem   = shift;
    my $parent = $elem->parent
      or return $elem->error('Element parent is not defined');
    my @contents = grep { $elem ne $_ } @{$parent->contents};
    $parent->contents(\@contents);
    $elem->parent(undef);
    1;
}

sub as_xml {
    my $w = XML::Atom::Syndication::Writer->new;
    $w->set_prefix('', $_[0]->ns);
    $w->as_xml($_[0]->elem, 1);
}

#--- utility

our %NS_MAP = (
               '0.3' => 'http://purl.org/atom/ns#',
               '1.0' => 'http://www.w3.org/2005/Atom',
);
our %NS_VERSION = reverse %NS_MAP;

sub set_ns {
    my $atom  = shift;
    my $param = shift;
    if (my $ns = delete $param->{Namespace}) {
        $atom->{ns}      = $ns;
        $atom->{version} = $NS_VERSION{$ns};
    } else {
        my $version = delete $param->{Version} || '1.0';
        $version = '1.0' if $version == 1;
        my $ns = $NS_MAP{$version}
          or return $atom->error("Unknown version: $version");
        $atom->{ns}      = $ns;
        $atom->{version} = $version;
    }
}

#--- autoload

sub DESTROY { }

use vars qw( $AUTOLOAD );

sub AUTOLOAD {
    (my $var = $AUTOLOAD) =~ s!.+::!!;
    no strict 'refs';
    *$AUTOLOAD = sub {
        @_ > 1
          ? $_[0]->set($_[0]->{ns}, $var, @_[1 .. $#_])
          : $_[0]->get($_[0]->{ns}, $var);
    };
    goto &$AUTOLOAD;
}

1;

__END__

=begin

=head1 NAME

XML::Atom::Syndication::Object - base class for all complex
Atom elements.

=head1 METHODS

=over

=item Class->new( $HASHREF );

Constructor. A HASH reference can be passed to initialize the object. Recognized 
keys are:

=over 8

=item Elem

A L<XML::Elemental::Element> that will be used as the source for this object. 
This object can be retreived or set using the C<elem> method.

=item Namespace

A string containing the namespace URI for the element.

=item Version

A SCALAR contain the Atom format version. This hash key can optionally be 
used instead of setting the element official Atom Namespace URIs using the 
Namespace key. Recognized values are 1.0 and 0.3. 1.0 is used as the default if 
Namespace and Version are not defined.

=back

=item $object->ns

A read-only accessor to the element's namespace URI.

=item $object->elem([$element])

An accessor that returns its underlying
L<XML::Elemental::Element> object. If C<$object> is provided
the element is set.

=item $object->element_name

Returns the Atom element name the object represents. 
B<This MUST be overwritten by all subclasses.>

=item $object->get_element($ns,$name)

Retrieves the values of a direct descendent of the object.
C<$ns> is a SCALAR contain a namespace URI or a
L<XML::Atom::Syndication::Namespace> object. C<$name> is the
local name of the element to retrieve.

When called in a SCALAR context returns the first elements
values. In an ARRAY context it returns all values for the
element.

=item $object->set_element($ns,$name,$val[,$attr,$add])

Sets the value of an element as a direct descendent of the
object. C<$ns> is a SCALAR contain a namespace URI or a
L<XML::Atom::Syndication::Namespace> object. C<$name> is the
local name of the element to retrieve. C<$val> can either be
a string, L<XML::Elemental::Element> object, or some
appropriate XML::Atom::Syndication object. C<$attr> is an
optional HASH reference used to specify attributes when $val
is a string value. It is ignored otherwise. C<$add> is an
optional boolean that will create a new node and append it
to any existing values as opposed to overwriting them which
is the default behavior.

Returns C<$val> if successful and C<undef> otherwise. The
error message can be retrieved through the object's
C<errstr> method.

=item $object->get_attribute($ns,$attr)

=item $object->get_attribute($attr)

Retrieves the value of an attribute. If one parameter is
passed the sole attribute is assumed to be the attribute name in
the same namespace as the object. If two are passed in it is
assumed the first is either a
C<XML::Atom::Syndication::Namespace> object or SCALAR
containing the namespace URI and the second the local name.

=item $object->set_attribute($ns,$attr,$val)

=item $object->set_attribute($attr,$val)

Sets the value of an attribute. If two parameters are passed
the first is assumed to be the attribute name and the second
its value. If three parameters are passed the first is
considered to be either a
C<XML::Atom::Syndication::Namespace> object or SCALAR
containing the namespace URI followed by the attribute name 
and new value.

=item $object->add($ns,$name,$val[,$attr])

An alias for C<set_element> with add boolean flag always set to true.

=item $object->remove

"Disowns" the object from its parent.

=item $object->as_xml

Output the element and all of its descendants are a full XML
document using L<XML::Atom::Syndication::Writer>. The object
will be the root element of the document with its namespace
URI set as the default.

=back

=head2 ELEMENT ACCESSORS

XML::Atom::Syndication::Object has the means to dynamically
create generic accessors that can get and set known elements
in the Atom namespace. This is a more convienant and less
verbose then using generic methods such as C<get_element> or
C<set_attribute>.

For instance if you wanted the title of an entry you could
get it with either of these lines:

 $entry->set_element('http://www.w3.org/2005/Atom','title','My Title');
 $entry->get_element('http://www.w3.org/2005/Atom','title');

 $entry->title('My Title');
 $entry->title;

The second set of methods are the element accessors that we are
talking about.

These accessors set and get text values. Other accessors
will exist in the object sublclasses to handle more complex 
data such as a link where you have a value AND attributes per 
element.

See the Atom Syndication Format specification or the documentation for
the specific classes for which elements you can expect from each.

Like its generic counterparts, if a "get" is made in an
array context and multiple values exist all will be returned,
otherwise only the first value is returned.

XML::Atom::Syndication does not enforce valid Atom
Syndication Format (ASF) document structure though its
really really encouraged. For validating an Atom document
use one of the Atom-enabled feed validators such as the one
found at http://www.feedvalidator.org/

Put another way, if you were to call C<$object->foo>, the
object would essentially go the equivalent of
C<$object->get_element($object->ns,'foo')>, It wouldn't
throw an error for calling an undefined method. Instead it
would simply return nothing -- or at least it should. (If it
does you have some bigger issues.) This was by design in
order for the module to be flexible as the format and
knowledge of its use settles. It is subject to change in the
future once support for version 0.3 of the format is
completely phased out.

=head2 ERROR HANDLING

All subclasses of XML::Atom::Syndication::Object inherit two
methods from L<Class::ErrorHandler>.

=over

=item Class->error($message)

=item $object->error($message)

Sets the error message for either the class Class or the
object C<$object> to the message C<$message>. Returns
C<undef>.

=item Class->errstr

=item $object->errstr

Accesses the last error message set in the class Class or
the object C<$object>, respectively, and returns that error
message.

=back

=head1 AUTHOR & COPYRIGHT

Please see the XML::Atom::Syndication manpage for author,
copyright, and license information.

=cut

=end
