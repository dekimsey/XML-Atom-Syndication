# Copyright (c) 2004 Timothy Appnel
# http://www.timaoutloud.org/
# This code is released under the Artistic License.
#
# XML::Atom::Syndication - simple lightweight client for 
# consuming Atom syndication feeds.
# 

package XML::Atom::Syndication;

use strict; 
use vars qw( $VERSION $atomic );
$VERSION = '0.01';

use XML::Parser;

sub instance {
    return $atomic if $atomic;
    $atomic = __PACKAGE__->new;
}

sub new {
    my $a = bless { }, $_[0];
    $a->{__parser} = XML::Parser->new( 
        Style => 'Elemental', 
            Elemental=>{
                Element=>'XML::Atom::Syndication::Element'}, 
                    Pkg => 'XML::Atom::Syndication',
                        Namespaces=>1 );
    # We dynamically add some placeholder functions for Class::XPath
    # so we can take advantage of the Document and Characters objects
    # Elemental can dynamically create for us.
    no strict 'refs';
    *{__PACKAGE__."::Document::query"} = 
        sub { $_[0]->contents->[0]->query($_[1]) };
    *{__PACKAGE__."::Document::_xpath_name"} = sub { undef };
    *{__PACKAGE__."::Document::_xpath_attribute_names"} = sub { () };
    *{__PACKAGE__."::Document::_xpath_attribute"} = sub { undef };
    *{__PACKAGE__."::Characters::_xpath_name"} = sub { undef };
    *{__PACKAGE__."::Characters::_xpath_attribute_names"} = sub { () };
    *{__PACKAGE__."::Characters::_xpath_attribute"} = sub { undef };
    $a;
}

sub get {
    require LWP::Simple;
    my $atom = $_[2] ? 
        LWP::Simple::mirror($_[1],$_[2]) :
            LWP::Simple::get($_[1]);
    return undef unless ($atom);
    $_[0]->{__parser}->parse($atom);
}

sub parse { $_[0]->{__parser}->parse($_[1]); } 
sub parse_file { $_[0]->{__parser}->parse_file($_[1]); }

1;

__END__

=begin

=head1 NAME

XML::Atom::Syndication - a simple lightweight client for consuming
Atom syndication feeds.

=head1 SYNOPSIS

 #!/usr/bin/perl -w
 use XML::Atom::Syndication;
 my $atomic = XML::Atom::Syndication->instance;
 my $doc = $atomic->get('http://www.timaoutloud.org/xml/atom.xml');
 my($feed_title)= $doc->query('/feed/title');
 print $feed_title->text_value."\n\n";
 foreach ($doc->query('//entry')) {
     my($title) = $_->query('title');
     my($summary) = $_->query('summary');
     my($link) = $_->query('link/@href');
     print $title->text_value."\n";
     print $summary->text_value."\n";
     print "$link\n\n";
 }

=head1 DESCRIPTION

While the real strength of the Atom effort is the API and its
unified format, retreiving feeds over HTTP and consuming their
contents, similar like with RSS, will be a common use. The module
endeavors to provide developers with a package that is simple,
lightweight and easy install.

Development began with two primary goals:

=over 4

=item To create something simpler and more lightweight then using
L<XML::Atom> for the specific and common purpose of fetching Atom
feeds.

=item To see how quickly and easily I could cobble together such a
package with existing modules.

=back

The latter of these goals will be less of a focus going forward.
That experiment has run its course. It went together quite easier
and having developed the L<XML::RSS::Parser> and L<XML::RAI>
modules, Atom data is much easier to process and use.

While keeping things simple was a priority, the XPath online
interface may be a bit too spartan. Going forward, refining this
interface so it is easier to work with will be a priority.
(Feedback is appreciated.)

=head1 METHODS

=item XML::Atom::Syndication->instance

Returns the XML::Atom::Syndication singleton. 

=item $instance->parse($text|IO_HANDLE)

Pass through to the C<parse> method of the L<XML::Parser> instance
being used by the client. Returns the root
L<XML::Atom::Syndication::Element> object for the feed.

=item $instance->parse_file(FILE_HANDLE)

Pass through to the C<parsefile> method of the L<XML::Parser>
instance being used by the client. Returns the root
L<XML::Atom::Syndication::Element> object for the feed.

=item $instance->get($url[,$file])

A method for fetching an Atom feed and parsing it. If an optional
file name is provided, the method will mirror the feed to the file
system location that is specified. Like the C<parse> methods,
returns the root L<XML::Atom::Syndication::Element> object for the
feed.

=head1 DEPENDENCIES

L<XML::Parser>, L<XML::Parser::Style::Elemental>, L<Class::XPath>,
L<LWP::Simple>

=head1 SEE ALSO

L<XML::Atom::Syndication::Element>, L<XML::Atom>

AtomEnabled Alliance - http://www.atomenabled.org/

=head1 BUGS

=item * Handling of unregistered XPath namespaces is incorrect.

=head1 TO DO

=over 4

=item * Refine the interface. Feedback appreciated.

=item * Implement auto-discovery C<find> method.

=item * Implement a means of passing through unescaped content
markup if desired. (This would be helpful with unescaped content
blocks.)

=item * Implement registration of additional namespace prefixes

=item * Implement means of LWP status/error reporting with C<get>.

=item * Implement ETag support within C<get>. (L<LWP::Simple> C<get>
and C<mirror> only uses last-modified headers which are not always
available with dynamic content.)

=back

=head1 LICENSE

The software is released under the Artistic License. The terms of
the Artistic License are described at
L<http://www.perl.com/language/misc/Artistic.html>.

=head1 AUTHOR & COPYRIGHT

Except where otherwise noted, XML::Atom::Syndication is Copyright
2004, Timothy Appnel, cpan@timaoutloud.org. All rights reserved.

=cut

=end