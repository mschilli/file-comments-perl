###########################################
# File::Comments::Plugin::Python 
# 2005, Mike Schilli <cpan@perlmeister.com>
###########################################

###########################################
package File::Comments::Plugin::Python;
###########################################

use strict;
use warnings;
use File::Comments::Plugin;
use Log::Log4perl qw(:easy);

our $VERSION = "0.01";
our @ISA     = qw(File::Comments::Plugin);

###########################################
sub init {
###########################################
    my($self) = @_;

    $self->register_suffix(".py");
}

###########################################
sub type {
###########################################
    my($self, $target) = @_;

    return "make";
}

###########################################
sub comments {
###########################################
    my($self, $target) = @_;

    return $self->extract_hashed_comments($target);
}

1;

__END__

=head1 NAME

File::Comments::Plugins::Python - Plugin to detect comments in makefiles

=head1 SYNOPSIS

    use File::Comments::Plugins::Python;

=head1 DESCRIPTION

File::Comments::Plugins::Python is a plugin for the File::Comments framework.

=head1 LEGALESE

Copyright 2005 by Mike Schilli, all rights reserved.
This program is free software, you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 AUTHOR

2005, Mike Schilli <cpan@perlmeister.com>
