###########################################
# File::Comments::Plugin::Perl 
# 2005, Mike Schilli <cpan@perlmeister.com>
###########################################

###########################################
package File::Comments::Plugin::Perl;
###########################################

use strict;
use warnings;
use File::Comments::Plugin;
use Log::Log4perl qw(:easy);
use Pod::Parser;

our $VERSION = "0.01";
our @ISA     = qw(File::Comments::Plugin);

###########################################
sub applicable {
###########################################
    my($self, $target, $cold_call) = @_;

    return 1 unless $cold_call;

    return 1 if $target->{content} =~ /^#!.*perl\b/;

    return 0;
}

###########################################
sub init {
###########################################
    my($self) = @_;

    $self->register_suffix(".pl");
    $self->register_suffix(".pm");
}

###########################################
sub type {
###########################################
    my($self, $target) = @_;

    return "perl";
}

###########################################
sub comments {
###########################################
    my($self, $target) = @_;

    my $comments = $self->extract_hashed_comments($target);

    my $pod = PodExtractor->new();
    $pod->parse_from_file($target->{path});
    push @$comments, @{$pod->pod_chunks()};

    return $comments;
}

###########################################
package PodExtractor;
###########################################
use Log::Log4perl qw(:easy);
our @ISA = qw(Pod::Parser);
###########################################

###########################################
sub new {
###########################################
    my($class) = @_;
    
    my $self = { chunks => [] };

    bless $self, $class;

    return $self;
}   

###########################################
sub textblock {
###########################################
    my ($self, $paragraph, $line_num) = @_;

    push @{$self->{chunks}}, $paragraph;
    DEBUG "Found textblock $paragraph";
}

sub command {}
sub verbatim {}
sub interior_sequence {}

###########################################
sub pod_chunks {
###########################################
    my ($self) = @_;

    return $self->{chunks};
}

1;

__END__

=head1 NAME

File::Comments::Plugins::Perl - Plugin to detect comments in perl scripts

=head1 SYNOPSIS

    use File::Comments::Plugins::Perl;

=head1 DESCRIPTION

File::Comments::Plugins::Perl is a plugin for the File::Comments framework.

This plugin currently just goes for one-line #... comments (no inlining)
and POD documentation. To be improved.

=head1 LEGALESE

Copyright 2005 by Mike Schilli, all rights reserved.
This program is free software, you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 AUTHOR

2005, Mike Schilli <cpan@perlmeister.com>
