package XML::Atom::Syndication::Thing;
use strict;

use base qw( XML::Atom::Syndication::Object );
use Symbol;

XML::Atom::Syndication::Thing->mk_accessors('XML::Atom::Syndication::Person',
                                            'author', 'contributor');
XML::Atom::Syndication::Thing->mk_accessors('XML::Atom::Syndication::Link',
                                            'link');
XML::Atom::Syndication::Thing->mk_accessors('XML::Atom::Syndication::Category',
                                            'category');
XML::Atom::Syndication::Thing->mk_accessors('XML::Atom::Syndication::Text',
                                            'rights', 'title');
XML::Atom::Syndication::Thing->mk_accessors('element', 'id', 'updated');

sub init {
    my $thing = shift;
    my %param = @_ == 1 ? (Stream => $_[0]) : @_;
    $thing->set_ns(\%param);
    if (%param) {
        if (my $stream = $param{Stream}) {
            my $parser = XML::Elemental->parser;
            my $xml;
            if (ref($stream) eq 'SCALAR') {
                $xml = $$stream;
            } elsif (ref $stream eq 'GLOB' || !ref($stream)) {
                my $fh;
                unless (ref $stream eq 'GLOB') {
                    $fh = gensym();
                    open $fh, $stream or die $!;
                } else {
                    $fh = $stream;
                }
                { local $/; $xml = <$fh>; }
                close $fh unless (ref $stream eq 'GLOB');
            } else {
                return;
            }
            if ($] > 5.008) {
                my ($enc) = $xml =~ m{<\?xml.*?encoding=['"](.*?)['"].*?\?>};
                if ($enc && lc($enc) ne 'utf-8') {    # need to convert to utf-8
                    eval {
                        require Encode;
                        Encode::from_to(Encode::encode_utf8($xml),
                                        $enc, 'utf-8');
                    };
                    warn $@ if $@;
                }
            }
            $thing->{doc}  = $parser->parse_string($xml);
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

1;
