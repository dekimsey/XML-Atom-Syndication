use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'XML::Atom::Syndication',
    'VERSION_FROM'	=> 'lib/XML/Atom/Syndication.pm', # finds $VERSION
    'PREREQ_PM'		=> { XML::Parser=>0, LWP::Simple=>0, 
                            XML::Parser::Style::Elemental=>0,
                                Class::XPath=>1.4 }, # e.g., Module::Name => 1.1
);
