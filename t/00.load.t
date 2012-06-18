# -*- perl -*-

# t/00.load.t - check module loading and create testing directory

# Make sure we're using the proper lib
# regardless of where this is called from
use FindBin qw($Bin);
use lib "$Bin/../lib/";

use Test::More tests => 6;
BEGIN {
    use_ok( 'Moose' );
    use_ok( 'XML::Simple' );
    use_ok( 'RemoteBackup' );
    use_ok( 'RemoteBackup::Machine' );
    use_ok( 'RemoteBackup::Database' );
    use_ok( 'RemoteBackup::Configuration' );
}
