###########################################
# File::Comments::Plugin -- 2005, Mike Schilli <cpan@perlmeister.com>
###########################################

###########################################
package File::Comments::Plugin;
###########################################

use strict;
use warnings;
use Log::Log4perl qw(:easy);

our $VERSION = "0.01";

###########################################
sub new {
###########################################
    my($class, %options) = @_;

    my $self = {
        %options,
    };

    bless $self, $class;

    $self->init();

    return $self;
}

###########################################
sub applicable {
###########################################
    my($self, $target, $cold_call) = @_;

    if($cold_call) {
        DEBUG "", __PACKAGE__, " doesn't accept cold calls";
        return 0;
    }

    DEBUG "", __PACKAGE__, " accepts";
    return 1;
}

###########################################
sub comments {
###########################################
    die "Mandatory method comments() not defined in ", ref $_[0];
}

###########################################
sub init {
###########################################
    die "Mandatory method init() not defined in ", ref $_[0];
}

###########################################
sub register_suffix {
###########################################
    my($self, $suffix) = @_;
    
    $self->mothership()->register_suffix($suffix, $self);
}

###########################################
sub register_base {
###########################################
    my($self, $base) = @_;
    
    $self->mothership()->register_base($base, $self);
}

###########################################
sub mothership { return $_[0]->{mothership} }
###########################################

###########################################
sub extract_c_comments {
###########################################
    my($self, $target) = @_;

    my @comments = ();

        # This will get confused with c strings containing things
        # like "/*", but good enough for now until we can hook in a full 
        # C parser/preprocessor.
    while($target->{content} =~ 
            m#/\*(.*?)\*/|
              ^\s*//(.*?)$
             #mxsg) {
        push @comments, defined $1 ? $1 : $2;
    }

    return \@comments;
}

###########################################
sub extract_html_comments {
###########################################
    my($self, $target) = @_;

    my @comments = ();

    while($target->{content} =~ m#<!--(.*?)-->#sg) {
        push @comments, $1;
    }

    return \@comments;
}

###########################################
sub extract_double_slash_comments {
###########################################
    my($self, $target) = @_;

    my @comments = ();

    while($target->{content} =~ 
            m#/^\s*//(.*?)
             #mxg) {
        push @comments, $1;
    }

    return \@comments;
}

###########################################
sub extract_hashed_comments {
###########################################
    my($self, $target) = @_;

    my @comments = ();

    while($target->{content} =~ m/^\s*#(.*)/mg) {
        push @comments, $1;
    }

    return \@comments;
}

1;

__END__

=head1 NAME

File::Comments::Plugin - Base class for all File::Comments plugins

=head1 SYNOPSIS

    use File::Comments::Plugin;

=head1 DESCRIPTION

File::Comments::Plugin is an abstract base class for all plugins
in the File::Comments framework.

=head1 LEGALESE

Copyright 2005 by Mike Schilli, all rights reserved.
This program is free software, you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 AUTHOR

2005, Mike Schilli <cpan@perlmeister.com>
