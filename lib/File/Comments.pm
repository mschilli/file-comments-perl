###########################################
# File::Comments -- 2005, Mike Schilli <cpan@perlmeister.com>
###########################################

###########################################
package File::Comments;
###########################################

use strict;
use warnings;
use Log::Log4perl qw(:easy);
use Sysadm::Install qw(:all);
use File::Basename;
use Module::Pluggable
  require     => 1,
  #search_path => [qw(File::Comments::Plugin)],
  ;

our $VERSION = "0.01";

###########################################
sub new {
###########################################
    my($class, %options) = @_;

    my $self = {
        suffixes   => {},
        plugins    => [],
        %options,
    };

    bless $self, $class;

        # Init plugins
    $self->init();

    return $self;
}

###########################################
sub init {
###########################################
    my($self) = @_;

    $self->{plugins} = [];

    for($self->plugins()) {
        DEBUG "Initializing plugin $_";
        my $plugin = $_->new(mothership => $self);
        push @{$self->{plugins}}, $plugin;
    }
}

###########################################
sub find_plugin {
###########################################
    my($self) = @_;

        # Is there a suffix handler defined?
    if(exists $self->{target}->{suffix} and
       exists $self->{suffixes}->{$self->{target}->{suffix}}) {

        for my $plugin (@{$self->{suffixes}->{$self->{target}->{suffix}}}) {
            DEBUG "Checking if ", ref $plugin, 
                  " is applicable for suffix ",
                  "'$self->{target}->{suffix}'";
            if($plugin->applicable($self->{target})) {
                DEBUG ref($plugin), " accepted";
                return $plugin;
            } else {
                DEBUG ref($plugin), " rejected";
            }
        }
    }

        # Go from door to door and check if some plugin wants to 
        # handle it. Set the 'cold_call' flag to let the plugin know
        # about our desparate move.
    for my $plugin (@{$self->{plugins}}) {
         DEBUG "Checking if ", ref $plugin, " is applicable for ",
               "file '$self->{target}->{path}' (cold call)";
        if($plugin->applicable($self->{target}->{path}, 
                               $self->{target}->{content}, 1)) {
            return $plugin;
        }
    }

    return undef;
}

###########################################
sub guess_type {
###########################################
    my($self, $target) = @_;

    if(ref $target) {
        $self->{target} = $target;
    } else {
        $self->{target} = File::Comments::Target->new(path => $target);
    }

    my $plugin = $self->find_plugin();

    if(! defined $plugin) {
        ERROR "No plugin found to handle $target";
        return undef;
    }

    return $plugin->type(); 
}

###########################################
sub comments {
###########################################
    my($self, $target) = @_;

    if(ref $target) {
        $self->{target} = $target;
    } else {
        $self->{target} = File::Comments::Target->new(path => $target);
    }

    my $plugin = $self->find_plugin();

    if(! defined $plugin) {
        ERROR "Type of $target couldn't be determined";
            # Just return and empty list
        return undef;
    }

    DEBUG "Calling ", ref $plugin, 
          " to handle $self->{target}->{path}";

    return $plugin->comments($self->{target});
}

###########################################
sub register_suffix {
###########################################
    my($self, $suffix, $plugin_obj) = @_;

    DEBUG "Registering ", ref $plugin_obj, 
          " as a handler for suffix $suffix";

        # Could be more than one, line them up
    push @{$self->{suffixes}->{$suffix}}, $plugin_obj;
}

##################################################
# Poor man's Class::Struct
##################################################
sub make_accessor {
##################################################
    my($package, $name) = @_;

    no strict qw(refs);

    my $code = <<EOT;
        *{"$package\\::$name"} = sub {
            my(\$self, \$value) = \@_;
    
            if(defined \$value) {
                \$self->{$name} = \$value;
            }
            if(exists \$self->{$name}) {
                return (\$self->{$name});
            } else {
                return "";
            }
        }
EOT
    if(! defined *{"$package\::$name"}) {
        eval $code or die "$@";
    }
}

###########################################
package File::Comments::Target;
###########################################
use Sysadm::Install qw(:all);
use File::Basename;

###########################################
sub new {
###########################################
    my($class, %options) = @_;

    my $self = {
        path       => undef,
        dir        => undef,
        file_name  => undef,
        file_base  => undef,
        content    => undef,
        suffix     => undef,
        %options,
    };

    bless $self, $class;

    $self->load($self->{path}, $self->{content});

    return $self;
}

###########################################
sub load {
###########################################
    my($self, $path, $content) = @_;

    $self->{content}   = $content unless $content;
    $self->{path}      = $path;
    $self->{content}   = slurp $path unless defined $self->{content};

    $self->{file_name} = basename($path);

    ($self->{dir}, $self->{file_name_base}, $self->{suffix}) =
        fileparse($path, qr{\.[^.]*$})
}

File::Comments::make_accessor("File::Comments::Target", $_)
   for qw(path file_name file_base content suffix dir);

1;

__END__

=head1 NAME

File::Comments - Extracts comments from files in various formats

=head1 SYNOPSIS

    use File::Comments;

    my $snoop = File::Comments->new();

        # *----------------
        # | program.c:
        # | /* comment */
        # | main () {}
        # *----------------
    my $comments = $snoop->comments("program.c");
        # => [" comment "]

        # *----------------
        # | script.pl:
        # | # comment
        # | print "howdy!\n"; # another comment
        # *----------------
    my $comments = $snoop->comments("script.pl");
        # => [" comment", " another comment"]

        # or just guess a file's type:
    my $type = $snoop->guess_type("program.c");    
        # => "c"

=head1 DESCRIPTION

File::Comments guesses the type of a given file, determines the format
used for comments, extracts all comments, and returns them as a reference
to an array of chunks.

Currently supported are Perl scripts, C/C++ programs, Java, makefiles,
JavaScript, Python and PHP.

The plugin architecture used by File::Comments makes it easy to add new
formats. To support a new format, a new plugin module has to be installed.
No modifications to the File::Comments codebase are necessary, new 
plugins will be picked up automatically.

File::Comments can also be used to simply guess a file's type. It it
somewhat more flexible than File::MMagic and File::Type.
File types in File::Comments are typically based on file name suffixes
(*.c, *.pl, etc.). If no suffix is available, or a given suffix
is ambiguous (e.g. if several plugins have registered a handler for
the same suffix), then the file's content is used to narrow down the
possibilities and arrive at a decision.

=head2 FILE TYPES

Currently, the following plugins are included in the File::Comments 
distribution:

    ###############################################
    # plugin                              type    #
    ###############################################
      File::Comments::Plugin::C          c 
      File::Comments::Plugin::Perl       perl
      File::Comments::Plugin::JavaScript js
      File::Comments::Plugin::Java       java
      File::Comments::Plugin::Makefile   makefile
      File::Comments::Plugin::HTML       html
      File::Comments::Plugin::Python     python
      File::Comments::Plugin::PHP        php

The constants listed in the I<type> column are the strings returned
by the C<guess_type()> method.

=head2 Writing new plugins

Writing a new plugin to add functionality to the File::Comments framework
is as simple as defining a new module, derived from the baseclass of all
plugins, C<File::Comments::Plugin>. Three additional methods are needed: 
C<init()>, C<type()>, and C<comments()>.

C<init()> gets called when the mothership finds the plugin and
initializes it. This is the time to register extensions that the plugin
wants to handle.

The second mandatory method for a plugin is C<type()>, which returns
a string, indicating the type of the file examined. Usually this can
be done without further ado, since a basic plugin will called only
on files which it registered for by suffix. Exceptions to this are
explained later.

The third method is C<comments()>, which returns a reference to an 
array of comment lines. The content of the source file to be examined
will be available in 

    $self->{target}->{content}

by the time C<comments()> gets called.

And that's it. Here's a functional basic plugin, registering a new 
suffix ".odd" with the mothership and expecting files with comment lines
that start with C<ODDCOMMENT>:

    ###########################################
    package File::Comments::Plugin::Oddball;
    ###########################################

    use strict;
    use warnings;
    use File::Comments::Plugin;

    our $VERSION = "0.01";
    our @ISA     = qw(File::Comments::Plugin);

    ###########################################
    sub init {
    ###########################################
        my($self) = @_;
    
        $self->register_suffix(".odd");
    }

    ###########################################
    sub type {
    ###########################################
        my($self) = @_;
    
        return "odd";
    }

    ###########################################
    sub comments {
    ###########################################
        my($self) = @_;
    
        # Some code to extract all comments from 
        # $self->{target}->{content}:
        my @comments = ($self->{target}->{content} =~ /^ODDCOMMENT:(.*)/);
        return \@comments;
    }

    1;

TODO: cold calls.

=head1 LEGALESE

Copyright 2005 by Mike Schilli, all rights reserved.
This program is free software, you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 AUTHOR

2005, Mike Schilli <cpan@perlmeister.com>
