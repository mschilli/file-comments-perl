###########################################
# File::Comments::Plugin::HTML 
# 2005, Mike Schilli <cpan@perlmeister.com>
###########################################

###########################################
package File::Comments::Plugin::HTML;
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

    $self->register_suffix(".htm");
    $self->register_suffix(".html");
    $self->register_suffix(".HTML");
    $self->register_suffix(".HTM");
}

###########################################
sub type {
###########################################
    my($self, $target) = @_;

    return "html";
}

###########################################
sub comments {
###########################################
    my($self, $target) = @_;

    return $self->extract_html_comments($target);
}

1;

__END__

=head1 NAME

File::Comments::Plugins::HTML - Plugin to detect comments in HTML source code

=head1 SYNOPSIS

    use File::Comments::Plugins::HTML;

=head1 DESCRIPTION

File::Comments::Plugins::HTML is a plugin for the File::Comments framework.

Needs to be upgraded with HTML::Parser.

=head1 LEGALESE

Copyright 2005 by Mike Schilli, all rights reserved.
This program is free software, you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 AUTHOR

2005, Mike Schilli <cpan@perlmeister.com>
