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
use PPI;
use Sysadm::Install qw(:all);

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

#####################################################
sub comments {
#####################################################
    my($self, $target) = @_;

    my $data = $target->{content};
    my($end) = ($data =~ /^__END__(.*)/ms);

    my @comments = $self->comments_from_snippet($target, $data);
    push @comments, $end if defined $end;

    return \@comments;
}

#####################################################
sub comments_from_snippet {
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
