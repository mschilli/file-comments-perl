######################################################################
# Makefile.PL for File::Comments
# 2005, Mike Schilli <cpan@perlmeister.com>
######################################################################
use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'         => 'File::Comments',
    'VERSION_FROM' => 'lib/File/Comments.pm', # finds $VERSION
    'PREREQ_PM'    => {
          Pod::Parser       => 0,
          Log::Log4perl     => 0,
          Sysadm::Install   => 0,
          Archive::Tar      => 0,
          Module::Pluggable => 0,
          }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'lib/File/Comments.pm',
       AUTHOR     => 'Mike Schilli <cpan@perlmeister.com>') : ()),
);
