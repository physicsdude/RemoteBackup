package RemoteBackup::Configuration;
use Moose; # automatically turns on strict and warnings
use Carp;
use XML::Simple;
use version; our $VERSION = qv('0.01');
use FindBin qw($Bin);
use lib "$Bin/../";
use RemoteBackup::Machine;
use RemoteBackup::Database;

=head1 NAME

RemoteBackup::Configuration - Read in XML configuration file and provide interface.

=head1 VERSION

This document describes RemoteBackup version 0.0.1


=head1 SYNOPSIS

 use RemoteBackup::Configuration;

 my $config = RemoteBackup::Configuration->new('file' => 'config/machine1.xml');

 while ( my $machine = $config->get_next_machine() ) {
   # do something
   while ( my $database = $config->get_database() ) {
     # do something
   }
 }

=head1 DESCRIPTION

Read in XML configuration file for backup modules and provide interface 
to the information in the config XML.

=head1 INTERFACE

Object fields:

=over 4

=cut

=item B<file> (Required) Configuration XML file. 
=cut

has 'file' => (
	is       => 'rw',
	isa      => 'Str',
	required => 1
);

=item B<machine> Ref to a Machine object
=cut

has 'machine' => (
	is  => 'rw',
	isa => 'RemoteBackup::Machine'
);

=item B<database> Ref to a database object
=cut

has 'database' => (
	is  => 'rw',
	isa => 'RemoteBackup::Database'
);

=item B<config> Ref to a hash of current config information.
=cut

has 'config' => (
	is  => 'rw',
	isa => 'ArrayRef'
);

=item B<machine_meta> Ref to hash of machine information
=cut

has 'machine_meta' => (
	is  => 'rw',
	isa => 'HashRef'
);

=back

=pod

Object methods:

=over 4

=cut

sub read_configuration {
	my $self = shift;

=item B<read> Read in the config XML.

 Input: None

 Output: Reference to config XML object

 Side Effect: XML::Simple object field 'xml' is set

=cut

	my $xs = XML::Simple->new();

	my $ref = $xs->XMLin(
		$self->file,
		ForceArray => [ 'database', 'machine', 'directory' ],
		KeyAttr    => 0,
	);

=pod 

The XML should be in the following format

 <?xml version="1.0" encoding="UTF-8"?>
 <machines>
     <machine>
 	<local_directory>./t/testdata/</local_directory>
 	<host>example.com</host>
 	<user>remotebk</user>
 	<directories>
 	    <directory>./test</directory>
 	    <directory>./test2</directory>
 	</directories>
 	<databases>
 	    <database>
 		<user>dbuser</user>
 		<pass>dbpass</pass>
 		<name>dbname</name>
 	    </database>
 	    <database>
 		<user>dbuser2</user>
 		<pass>dbpass2</pass>
 		<name>dbname2</name>
 	    </database>
 	</databases>
     </machine>
     <machine>
 	<local_directory>./t/testdata/</local_directory>
 	<host>example.com</host>
 	<user>remotebk</user>
 	<directories>
 	    <directory>./.ssh</directory>
 	</directories>
     </machine>
 </machines>


 The data structure will look like

 {
     'machine' => [
 		{
 		  'host' => 'example.com',
 		  'directories' => {
 				   'directory' => [
 						  './test',
 						  './test2'
 						]
 				 },
 		  'databases' => [
 				 {
 				   'database' => [
 						 {
 						   'database' => 'dbname',
 						   'pass' => 'dbpass',
 						   'user' => 'dbuser'
 						 },
 						 {
 						   'database' => 'dbname2',
 						   'pass' => 'dbpass2',
 						   'user' => 'dbuser2'
 						 }
 					       ]
 				 }
 			       ],
 		  'user' => 'remotebk'
 		},

=cut

	$self->config($ref->{'machine'});
	return $self->config();

}

sub get_next_machine {
	my $self = shift;

=item B<get_next_machine> Get the next set of machine information

 Input: None

 Output: Reference to data structure with next machine information or undef.

 Side Effect: Object field 'machine' is updated.

=cut

	# Clear the machine information
	undef $self->{'machine'};

	# Get the next machine info array ref
	$self->{'machine_meta'} = shift @{ $self->{'config'} };

	# If it is undefined we're done
	return if not $self->{'machine_meta'};

	# Create a new Machine object
	$self->{'machine'} = RemoteBackup::Machine->new(
		{
			'local_directory' => $self->{'machine_meta'}{'local_directory'},
			'user'            => $self->{'machine_meta'}{'user'},
			'host'            => $self->{'machine_meta'}{'host'},
			'directories'     => $self->{'machine_meta'}{'directories'}{'directory'},
		}
	);

	# Return a ref to the machine object
	return $self->{'machine'};
}

sub get_next_database {
	my $self = shift;

=item B<get_next_database> Get the next set of database information

 Input: None

 Output: Reference to data structure with next database information or undef.

 Side Effect: Object field 'database' is updated.

=cut

	# Clear the machine information
	undef $self->{'database'};

	# Get the next set of db info for this machine
	my $db_info = shift @{ $self->{'machine_meta'}{'databases'}{'database'} };

	# If there is no db then we're done
	return if not $db_info;

	# Create a new database object
	$self->{'database'} = RemoteBackup::Database->new(
		{
			'machine' => $self->{'machine'},
			'user'    => $db_info->{'user'},
			'pass'    => $db_info->{'pass'},
			'name'    => $db_info->{'name'},
		}
	);

	# Return a reference to the database object
	return $self->{'database'};
}

=back
=cut

__PACKAGE__->meta->make_immutable;

1; # Magic true value required at end of module

=head1 CONFIGURATION AND ENVIRONMENT


=head1 DEPENDENCIES

XML::Simple

=head1 INCOMPATIBILITIES

None reported.


=head1 BUGS AND LIMITATIONS

No bugs have been reported.


=head1 AUTHOR

Bryan Gmyrek  C<< bryangmyrek@gmail.com >>


=head1 LICENSE AND COPYRIGHT

Copyright (c) 2010, Bryan Gmyrek C<< bryangmyrek@gmail.com >>.
All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See C<perldoc perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE ''AS IS'' WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
