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
use Sysadm::Install qw(:all);

our $VERSION = "0.01";
our @ISA     = qw(File::Comments::Plugin::Makefile);
our $USE_PPI = 1;

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
    $self->register_suffix(".PM");
    $self->register_suffix(".PL");
}

###########################################
sub type {
###########################################
    my($self, $target) = @_;

    return "perl";
}

#####################################################
sub comments {
#####################################################
    my($self, $target) = @_;

    my $data = $target->{content};
    my @comments;

    if($USE_PPI) {
        require PPI;
        my($end) = ($data =~ /^__END__(.*)/ms);
        @comments = $self->comments_parse_ppi($target, $data);
        push @comments, $end if defined $end;
    } else {
        require Pod::Parser;
        @comments = @{$self->comments_parse_simple($target, $data)};
    }

    return \@comments;
}

#####################################################
sub comments_parse_ppi {
#####################################################
    my($self, $target, $src) = @_;

    my $doc = PPI::Document->new($src); #bar
    my @comments = ();

    if(!defined $doc) {
        # Parsing perl script failed. Just return everything.
        WARN "Parsing $target->{path} failed";
        return $src;
    }

    $doc->find(sub {
        return if ref($_[1]) ne "PPI::Token::Comment" and
                  ref($_[1]) ne "PPI::Token::Pod";
        my $line = $_[1]->content();
            # Delete leading '#' if it's a comment
        $line = substr($line, 1) if ref($_[1]) eq "PPI::Token::Comment";
        chomp $line;
        push @comments, $line;
    });

    return @comments;
}

#####################################################
sub comments_parse_simple {
#####################################################
    my($self, $target, $src) = @_;

    my $comments = $self->extract_hashed_comments($target);

    my $pod = PodExtractor->new();
    $pod->parse_from_file($target->{path});
    push @$comments, @{$pod->pod_chunks()};

    return $comments;
}

###########################################
package PodExtractor;
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

Uses L<PPI> to parse Perl code. If this isn't desired (PPI had memory
problems at the time of this writing), specify

    File::Comments::Plugins::Perl::USE_PPI = 0;

and another, simpler parser will be used. It just goes for one-line 
#... comments (no inlining) and POD via L<Pod::Parser>.

=head1 LEGALESE

Copyright 2005 by Mike Schilli, all rights reserved.
This program is free software, you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 AUTHOR

2005, Mike Schilli <cpan@perlmeister.com>
