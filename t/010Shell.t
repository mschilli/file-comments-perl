######################################################################
# Test suite for File::Comments
# by Mike Schilli <cpan@perlmeister.com>
######################################################################

use warnings;
use strict;

use Test::More qw(no_plan);
use Sysadm::Install qw(:all);
use Log::Log4perl qw(:easy);

BEGIN { use_ok('File::Comments') };
use File::Comments::Plugin;

my $eg = "eg";
$eg = "../eg" unless -d $eg;

my $snoop = File::Comments->new();

######################################################################
my $tmpfile = "$eg/shell.sh";
END { unlink $tmpfile }
blurt(<<EOT, $tmpfile);
#!/bin/bash
# First comment
echo foo
# Second
ls -lt bar
# Third
EOT

my $chunks = $snoop->comments($tmpfile);

ok($chunks, "find shell comments");
is($chunks->[0], "!/bin/bash", "hashed comment");
is($chunks->[1], " First comment", "hashed comment");
is($chunks->[2], " Second", "hashed comment");
is($chunks->[3], " Third",   "hashed comment");

my $stripped = $snoop->stripped($tmpfile);
is($stripped, "echo foo\nls -lt bar\n", "stripped comments");

my $tmpfile2 = "$eg/testscript";
END { unlink $tmpfile2 }
blurt(<<EOT, $tmpfile2);
#!/bin/bash
# First comment
echo foo
# Second
ls -lt bar
# Third
EOT
$stripped = $snoop->stripped($tmpfile2);

is ($snoop->guess_type($tmpfile), 'shell', 'Shell type matched');
is ($snoop->guess_type($tmpfile2), 'shell', 'Shell type matched');
