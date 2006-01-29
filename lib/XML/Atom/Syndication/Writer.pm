package XML::Atom::Syndication::Writer;
use strict;

use base qw( Class::ErrorHandler );

use XML::Writer;
use XML::Elemental::Util qw( process_name );

my %NSPrefix = (    # default prefix table.
                    # ''        => "http://www.w3.org/2005/Atom",
    dc        => "http://purl.org/dc/elements/1.1/",
    dcterms   => "http://purl.org/dc/terms/",
    sy        => "http://purl.org/rss/1.0/modules/syndication/",
    trackback => "http://madskills.com/public/xml/rss/module/trackback/",
    xhtml     => "http://www.w3.org/1999/xhtml",
    xml       => "http://www.w3.org/XML/1998/namespace"
);

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    $self->init(@_);
}

sub init {
    my %nsp = %NSPrefix;    # clone
    $_[0]->{__PREFIX} = \%nsp;
    $_[0]->{__NS}     = {reverse %nsp};
    $_[0];
}

sub set_prefix {
    $_[0]->{__NS}->{$_[2]}     = $_[1];
    $_[0]->{__PREFIX}->{$_[1]} = $_[2];
}

sub get_prefix    { $_[0]->{__NS}->{$_[1]} }
sub get_namespace { $_[0]->{__PREFIX}->{$_[1]} }

sub as_xml {
    my ($self, $node, $is_full, $encoding) = @_;
    $encoding ||= 'utf-8';
    my $xml = '';
    my $w;
    if ($is_full) {    # full doc
        my ($name, $ns) = process_name($node->name);
        $w = XML::Writer->new(
            OUTPUT     => \$xml,
            NAMESPACES => 1,
            PREFIX_MAP => $self->{__NS},

            # FORCED_NS_DECLS => [ $ns ]
        );
        $w->xmlDecl($encoding);
    } else {           # fragment
        $w = XML::Writer->new(OUTPUT => \$xml, UNSAFE => 1);
    }
    my $dumper;
    $dumper = sub {
        my $node = shift;
        return encode_xml($w, $node->data)
          if (ref $node eq 'XML::Elemental::Characters');
        my ($name, $ns) =
          process_name($node->name);    # it must be an element then.
        my $tag = $is_full ? [$ns, $name] : $name;
        my @attr;
        my $a        = $node->attributes;
        my $children = $node->contents;
        foreach (keys %$a) {
            my ($aname, $ans) = process_name($_);
            next
              if (   $ans eq 'http://www.w3.org/2000/xmlns/'
                  || $aname eq 'xmlns');
            my $key = $is_full && $ans ? [$ans, $aname] : $aname;
            push @attr, $key, $a->{$_};
        }
        if (@$children) {
            $w->startTag($tag, @attr);
            map { $dumper->($_) } @$children;
            $w->endTag($tag);
        } else {
            $w->emptyTag($tag, @attr);
        }
    };
    $dumper->($node);

    # $w->end; # this adds a character return we don't want.
    $xml;
}

# utility for intelligent use of cdata.
sub encode_xml {
    my ($w, $data, $nocdata) = @_;
    return unless defined($data);
    if (
        !$nocdata
        && $data =~ m/
        <[^>]+>  ## HTML markup
        |        ## or
        &(?:(?!(\#([0-9]+)|\#x([0-9a-fA-F]+))).*?);
                 ## something that looks like an HTML entity.
    /x
      ) {

# $w->cdata($data); # this was inserting a extra character into returned strings.
        my $str = $w->characters($data);
        $str =~ s/]]>/]]&gt;/g;
        '<![CDATA[' . $str . ']]>';
      } else {
        $w->characters($data);
    }
}

1;

__END__

=head1 NAME

XML::Atom::Syndication::Writer - a class for serializing
XML::Atom::Syndication nodes into XML.

=head1 DESCRIPTION

This class uses XML::Writer to serialize
XML::Atom::Syndication nodes into XML.

The following namespace prefixes are automatically defined
when each writer is instaniated:

 dc            http://purl.org/dc/elements/1.1/
 dcterms       http://purl.org/dc/terms/
 sy            http://purl.org/rss/1.0/modules/syndication/
 trackback     http://madskills.com/public/xml/rss/module/trackback/
 xhtml         http://www.w3.org/1999/xhtml
 xml           http://www.w3.org/XML/1998/namespace

=head1 METHODS

=over

=item XML::Atom::Syndication::Writer->new

Constructor.

=item $writer->set_prefix($prefix,$nsuri)

Assigns a namespace prefix to a URI.

=item $writer->get_prefix($prefix)

Returns the namespace URI assigned to the given prefix.

=item $writer->get_namespace($nsuri)

Returns the namespace prefix assigned to the given URI.

=item $writer->as_xml($node,$is_full,$encoding)

Returns an XML representation of the given node and all its
descendents. By default the method returns an XML fragment
unless C<$is_full> is a true value. If C<$is_full> is true
an XML declartion is prepended to the output. An
C<$encoding> parameter can be passed in to set the encoding
attribute of the XML declaration. The default if UTF-8.

=back

=head1 AUTHOR & COPYRIGHT

Please see the L<XML::Atom::Syndication> manpage for author,
copyright, and license information.

=cut

=end
