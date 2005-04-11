######################################################################
# Test suite for Archive::Tar::Wrapper
# by Mike Schilli <cpan@perlmeister.com>
######################################################################

use warnings;
use strict;
use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($ERROR);

use File::Temp qw(tempfile);

my $TARDIR = "data";
$TARDIR = "t/$TARDIR" unless -d $TARDIR;

use Test::More qw(no_plan);
BEGIN { use_ok('Archive::Tar::Wrapper') };

my $arch = Archive::Tar::Wrapper->new();

ok($arch->read("$TARDIR/foo.tgz"), "opening compressed tarfile");

ok($arch->locate("001Basic.t"), "find 001Basic.t");
ok($arch->locate("./001Basic.t"), "find ./001Basic.t");

ok(!$arch->locate("nonexist"), "find nonexist");

# Add a new file
my $tmploc = $arch->locate("001Basic.t");
ok($arch->add("foo/bar/baz", $tmploc), "adding file");
ok($arch->locate("foo/bar/baz"), "find added file");

# Make a tarball
my($fh, $filename) = tempfile(CLEANUP => 1);
ok($arch->tarup($filename), "Tarring up");

# List 
my $a2 = Archive::Tar::Wrapper->new();
ok($a2->read($filename), "Reading in new tarball");
my @elements = $a2->list_all();
my $got = join " ", sort @elements;
is($got, "001Basic.t foo/bar/baz", "Check list");

my $f1 = $a2->locate("001Basic.t");
my $f2 = $a2->locate("foo/bar/baz");
ok(-s $f1 > 0, "Checking tarball files sizes");
ok(-s $f2 > 0, "Checking tarball files sizes");

is(-s $f1, -s $f2, "Comparing tarball files sizes");

