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
my $tmpfile = "$eg/foo.baz";
END { unlink $tmpfile }
blurt(<<EOT, $tmpfile);
dfkgsrugslgjlsghrlhslgrhsleghlseg
gselghelruiglshrgs
gslekruhl
EOT

is ($snoop->guess_type($tmpfile), undef, 'No type matched for file');
my $chunks = $snoop->comments($tmpfile);
is (@$chunks, 0, 'No comments in unknown file');

my $target = File::Comments::Target->new(path => $tmpfile);
is ($snoop->guess_type($target), undef, 'No type matched for target');
$chunks = $snoop->comments($target);
is (@$chunks, 0, 'No comments in unknown target');
