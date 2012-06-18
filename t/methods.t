#!/usr/bin/perl
use warnings;
use strict;
use FindBin qw($Bin);
use lib "$Bin/../lib/";

use Test::More tests=> 30;

BEGIN {
    use_ok( 'RemoteBackup' );
    use_ok( 'RemoteBackup::Machine' );
    use_ok( 'RemoteBackup::Database' );
    use_ok( 'RemoteBackup::Configuration' );
}

# Configuration.pm

my @configuration_methods = (
# Object fields
'file', 'machine', 'database', 'config',

# Executable methods
'read_configuration', 'get_next_machine', 
'get_next_database',

);

# Test that methods are defined for the object
can_ok('RemoteBackup::Configuration', @configuration_methods);

# Create new Configuration object
my $config = RemoteBackup::Configuration->new(
  {
		'file' => "$Bin/../config/example.xml",
  }
);

# Test that fields were set correctly
is($config->file, "$Bin/../config/example.xml", 'file field test.');

# Test the read method
#
#  there should be 2 machine entries
is(ref($config->read_configuration()),'ARRAY',"Test configuration read method.");

# Test config hash ref is set
is(ref($config->config()),'ARRAY',"Test configuration read method.");

# get_next_machine should return a reference to a Machine object
is(ref($config->get_next_machine()),'RemoteBackup::Machine',"Test configuration get_next_machine method.");
# get_next_database should return a reference to a Database object
is(ref($config->get_next_database()),'RemoteBackup::Database',"Test configuration get_next_database method.");
is(ref($config->get_next_database()),'RemoteBackup::Database',"Test configuration get_next_database method.");
# Test that exhausted machines
is(ref($config->get_next_database()),'',"Test configuration get_next_database method.");
# Test getting more machines
is(ref($config->get_next_machine()),'RemoteBackup::Machine',"Test configuration get_next_machine method.");
# Test that exhausted databases
is(ref($config->get_next_machine()),'',"Test configuration get_next_machine method.");

# Machine.pm

my @machine_methods = (
# Object fields
'user','host','directories',
'local_directory',

# Executeable methods
'backup',
);

# Test that methods are defined for the object
can_ok('RemoteBackup::Machine', @machine_methods);

# Create new Machine object
my $machine = RemoteBackup::Machine->new(
  {
		'host' => 'example.com',
		'user' => 'remotebk',
		'directories' => [ './test/', './test2/' ],
		'local_directory' => "$Bin/testdata/",
  }
);

# Test that fields were set correctly
is($machine->host, 'example.com', 'Test host field.');
is($machine->user, 'remotebk', 'Test remotebk field.');
is(ref($machine->directories), 'ARRAY', 'Test directories field.');
is($machine->local_directory, "$Bin/testdata/", 'Test local_directory field.');

SKIP: {
	skip "Need remote server setup", 1 unless $ENV{RB_RUN_REMOTE};
# Test backup method
# Two directories were specified for backup
# so 2 should be returned
	is($machine->backup(),2,'Test backup method.');
}

# Database.pm

my @database_methods = (
# Object fields
'user','pass','name','machine',

# Executeable methods
'backup',
);

# Test that methods are defined for the object
can_ok('RemoteBackup::Database', @database_methods);

# Create new Database object
my $db = RemoteBackup::Database->new(
  {
		'machine' => $machine,
		'user' => 'dbuser',
		'pass' => 'dbpass',
		'name' => 'dbname',
  }
);

# Test that fields were set correctly
#is($db->machine, 'Machine', 'Machine field test.');
is(ref($db->machine), 'RemoteBackup::Machine', 'machine field test.');
is($db->user, 'dbuser', 'user field test.');
is($db->pass, 'dbpass', 'pass field test.');
is($db->name, 'dbname', 'name field test.');

# Methods to test
my @remotebackup_methods = (
# Object fields
'config_xml', 'config',

# Executeable methods
'backup_all',
);

# Test that methods are defined for the object
can_ok('RemoteBackup', @remotebackup_methods);

SKIP: {
	skip "Need remote server with database setup", 1 unless $ENV{RB_RUN_REMOTE};
# Test remote db backup
	is($db->backup($machine), 355, 'Backup database test.');
}

# Create new RemoteBackup object
my $rb = RemoteBackup->new({'config_xml' => "$Bin/../config/example.xml"});

# Test that fields were set correctly
is($rb->config_xml, "$Bin/../config/example.xml", 'Config XML test.');
is(ref($rb->config), 'RemoteBackup::Configuration', 'Configuration object isntance test.');
SKIP: {
	skip "Need remote server with database setup", 1 unless $ENV{RB_RUN_REMOTE};
	is($rb->backup_all(), 2, 'Backup all test.');
}

done_testing();
