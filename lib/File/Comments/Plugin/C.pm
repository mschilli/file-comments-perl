###########################################
# File::Comments::Plugin::C -- 2005, Mike Schilli <cpan@perlmeister.com>
###########################################

###########################################
package File::Comments::Plugin::C;
###########################################

use strict;
use warnings;
use File::Comments::Plugin;
use Log::Log4perl qw(:easy);

our $VERSION = "0.01";
our @ISA     = qw(File::Comments::Plugin);

###########################################
sub applicable {
###########################################
    my($self, $target, $cold_call) = @_;

    if($cold_call) {
        DEBUG __PACKAGE__, " doesn't accept cold calls";
        return 0;
    }

    DEBUG __PACKAGE__, " accepts";
    return 1;
}

###########################################
sub init {
###########################################
    my($self) = @_;

    $self->{mothership}->register_suffix(".c", $self);
}

###########################################
sub type {
###########################################
    my($self) = @_;

    return "c";
}

###########################################
sub comments {
###########################################
    my($self) = @_;

    return qw(foo bar baz);
}

1;

__END__

=head1 NAME

File::Comments::Plugins::C - Plugin to detect/analyze C source code

=head1 SYNOPSIS

    use File::Comments::Plugins::C;

=head1 DESCRIPTION

File::Comments::Plugins::C is a plugin for the File::Comments framework.

=head1 LEGALESE

Copyright 2005 by Mike Schilli, all rights reserved.
This program is free software, you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 AUTHOR

2005, Mike Schilli <cpan@perlmeister.com>
