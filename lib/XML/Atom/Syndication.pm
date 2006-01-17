package XML::Atom::Syndication;
use strict;
use warnings;

use vars qw($VERSION);
$VERSION = '0.9_03';

package XML::Atom::Syndication::Namespace;
use strict;

sub new {
    my $class = shift;
    my ($prefix, $uri) = @_;
    bless {prefix => $prefix, uri => $uri}, $class;
}

sub DESTROY { }

use vars qw( $AUTOLOAD );

sub AUTOLOAD {
    (my $var = $AUTOLOAD) =~ s!.+::!!;
    no strict 'refs';
    ($_[0], $var);
}

1;

__END__

=begin

=head1 NAME

XML::Atom::Syndication - A SAX-based library for working
with Atom Syndication Format (RFC 4287) feeds.

=head1 DESCRIPTION

This project is the result of scratching ones own itch. I
was writing some web software needed a full-featured library
for working with Atom feeds that was easy to distribute and
install on wide range of envrionments. Many of my software's
target audience are relative novices working with low-cost
shared hosting environments. (A significant number don't
even have shell access!) Creating a library that was easy to
install even by FTP was a paramount requirement that many
other options failed to meet.

Originally the module began as a very spartan XPath driven
interface. At the time the format had just been introduced
and was still vague and very extremely volitle. It was a
pretty wretched piece of software, but it got me through
while the Atom Working Group worked out the details of the
Atom Syndication Format.

Since that time the Atom Syndication Format (ASF) has made
its way through numerous drafts and is now an approved
standard of the IETF as RFC 4287.

Beginning with version 0.9, XML::Atom::Syndication has been
completely rewritten to provide better functionality and
structure in working with a stable Atom format
specification.

The interface and a fair bit of the code was based on that
of L<XML::Atom>. It owes a great deal to its authors, Ben
Trott and Tatsuhiko Miyagawa, and all its contributors.

As of version 0.16, XML::Atom defaults to version 0.3 which
is now deprecated.  Baseline 1.0 support has been built-in
however many of the changes that were introduced (category
elements, dropping the mode attribute in the content
construct) have yet to be implemented. I'm sure this will
change eventually, but it currently is a differentiator
between the two implementations. XML::Atom::Syndication
supports 0.3, but defaults 1.0.

More importantly this implementation is not tied to specific
XML parsers -- XML::LibXML or XML::XPath (expat) as is the
case with XML::Atom. Both of these parsers libraries require
compilation  which can be a major hurdle if you are not in
charge of your hosting environment. By using SAX at the
core, this Atom implementation will work with whatever
parser it can find including the default pure perl option
that XML::SAX is distributed with.

Unlike XML::Atom, this distribution focuses on the Atom
syndication format and not the publishing protocol. The
publishing protocol is still being worked out and is not an
official standard at this time.

=head1 DEPENDENCIES

=over

=item L<XML::Elemental> 2.0

=item L<XML::Writer> 0.600

=item L<Class:ErrorHandler>

=item L<Encode>

=item L<MIME::Base64>

=back

=head1 SEE ALSO

L<XML::Atom>, L<XML::RAI>

http://www.atomenabled.org/developers/syndication/atom-format-spec.php

F<TODO>

=head1 LICENSE

The software is released under the Artistic License. The
terms of the Artistic License are described at
L<http://www.perl.com/language/misc/Artistic.html>.

=head1 AUTHOR & COPYRIGHT

Except where otherwise noted, XML::Atom::Syndication is
Copyright 2004-2006, Timothy Appnel, tima@cpan.org.
All rights reserved.

=cut

=end
