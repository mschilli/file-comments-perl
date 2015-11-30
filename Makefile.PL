######################################################################
# Makefile.PL for File::Comments
# 2005, Mike Schilli <cpan@perlmeister.com>
######################################################################
use ExtUtils::MakeMaker;

my $meta_merge = {
    META_MERGE => {
        resources => {
            repository  => 'http://github.com/mschilli/file-comments-perl.git',
        },
    }
};

my $min_perl_ver = {
    'MIN_PERL_VERSION'  => '5.6.0'
};

WriteMakefile(
    'NAME'              => 'File::Comments',
    'VERSION_FROM'      => 'lib/File/Comments.pm', # finds $VERSION
    'ABSTRACT_FROM'     => 'lib/File/Comments.pm',
    'AUTHOR'            => 'Mike Schilli <cpan@perlmeister.com>',
    'PREREQ_PM'         => {
          HTML::TokeParser  => 2.28,
          HTML::TreeBuilder => 0,
          PPI               => 1.115,
          Log::Log4perl     => 0.50,
          Sysadm::Install   => 0.11,
          Module::Pluggable => 2.4,
          Pod::Parser       => 1.14,
          }, # e.g., Module::Name => 1.1
    $ExtUtils::MakeMaker::VERSION >= 6.50 ? (%$meta_merge)   : (),
    $ExtUtils::MakeMaker::VERSION >= 6.48 ? (%$min_perl_ver) : (),
);
