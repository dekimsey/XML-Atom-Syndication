package XML::Atom::Syndication::Content;
use strict;

use base qw( XML::Atom::Syndication::Object );

use Encode;
use MIME::Base64 qw( encode_base64 decode_base64 );

use constant XMLNS => 'http://www.w3.org/XML/1998/namespace';

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    $self->init(@_) or return $class->error($self->errstr);
    $self;
}

sub init {
    my $content = shift;
    my %param = @_ == 1 ? (Body => $_[0]) : @_;
    $content->SUPER::init(%param);
    my $e = $content->elem;
    if ($e && !$content->mode) {
        my ($mode) = _determine_mode($e->text_content);
        $e->attributes->{'{}mode'} = $mode;
    }
    if ($param{Body}) {
        $content->body($param{Body});
    }
    if ($param{Type}) {
        $content->type($param{Type});
    }
    $content;
}

sub element_name { 'content' }
sub get          { shift->get_attribute(@_) }
sub set          { shift->set_attribute(@_) }

sub mode { $_[0]->get_attribute('mode') } # not in 1.0

sub base {
    my $content = shift;
    $content->set_attribute(XMLNS,'base', $_[0]) if @_;
    $content->get_attribute(XMLNS,'base');
}

sub language {
    my $content = shift;
    $content->set_attribute(XMLNS,'lang', $_[0]) if @_;
    $content->get_attribute(XMLNS,'lang');
}
*lang = \&language;

sub body { # Review 4.1.3.3 We're not handling this correctly in terms of 1.0
    my $content = shift;
    my $elem    = $content->elem;
    if (@_) {    # set
        my $data = shift;
        my ($mode, $node) =
          _determine_mode($data);    # sucky, but reuses xml test parse.
        if ($mode eq 'base64') {     # is binary
            Encode::_utf8_off($data);
            require XML::Elemental::Characters;
            my $b = XML::Elemental::Characters->new;
            $b->data(encode_base64($data, ''));
            $b->parent($elem);
            $elem->contents([$b]);
            $elem->attributes->{'{}mode'} = 'base64';
        } elsif ($mode eq 'xml') {    # is xml
            $node->parent($elem);
            $elem->contents([$node]);
            $elem->attributes->{'{}mode'} = 'xml';
        } else {                      # is text
            my $text = XML::Elemental::Characters->new;
            $text->data($data);
            $text->parent($elem);
            $elem->contents([$text]);
            $elem->attributes->{'{}mode'} = 'escaped';
        }
    } else {    # get
        unless (exists $content->{__body}) {
            my $mode = $elem->attributes->{'{}mode'} || 'xml';
            if ($mode eq 'xml') {
                my @children =
                  grep { ref($_) eq 'XML::Elemental::Element' }
                  @{$elem->contents};
                if (@children) {
                    my ($local) =
                      $children[0]->name =~ /{.*}(.+)/;    # process name
                    @children = @{$children[0]->contents}
                      if (@children == 1 && $local eq 'div');
                    $content->{__body} = '';
                    my $w = XML::Atom::Syndication::Writer->new;
                    $w->set_prefix('', 'http://www.w3.org/1999/xhtml');
                    map { $content->{__body} .= $w->as_xml($_) } @children;
                } else {
                    $content->{__body} = $elem->text_content;
                }
                if ($] >= 5.008) {
                    Encode::_utf8_on($content->{__body});
                    $content->{__body} =~ s/&#x(\w{4});/chr(hex($1))/eg;
                    Encode::_utf8_off($content->{__body});
                }
            } elsif ($mode eq 'base64') {
                my $raw = decode_base64($elem->text_content);
                if ($content->type && $content->type =~ m!text/!) {
                    $content->{__body} = eval { Encode::decode('utf-8', $raw) }
                      || $raw;
                } else {
                    $content->{__body} = $raw;
                }
            } elsif ($mode eq 'escaped') {
                $content->{__body} = $elem->text_content;
            } else {
                $content->{__body} = undef;
            }
        }
    }
    $content->{__body};
}

sub is_printable {
    my $data = shift;
    my $decoded = (
                   Encode::is_utf8($data)
                   ? $data
                   : eval { Encode::decode("utf-8", $data, Encode::FB_CROAK); }
    );
    !$@ && $decoded =~ /^\p{IsPrint}*$/;
}

sub _determine_mode {
    my $data = shift;
    unless (is_printable($data)) {
        return 'base64';
    } else {
        my $copy =
          '<div xmlns="http://www.w3.org/1999/xhtml">' . $data . '</div>';
        my $node;
        eval {
            require XML::Elemental;
            my $parser = XML::Elemental->parser;
            my $xml    = $parser->parse_string($copy);
            $node = $xml->contents->[0];
        };
        !$@ && $node ? ('xml', $node) : 'escaped';    # sucky
    }
}

1;

__END__

=begin

=head1 NAME

XML::Atom::Syndication::Content - class representing Atom
entry content

=head1 NOTES

Due to extensive clarifications and refinements in the
processing model from 0,3 to 1.0 this module is not what it
needs to be. It currently reflects 0.3 handling. 

Need to review the Atom 1.0 processing module (Section
4.1.3.3 in the ASF specification) and make extensive
changes.

=head1 AUTHOR & COPYRIGHT

Please see the XML::Atom::Syndication manpage for author,
copyright, and license information.

=cut

=end