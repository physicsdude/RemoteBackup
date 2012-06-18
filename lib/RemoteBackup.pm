package RemoteBackup;
use Moose; # automatically turns on strict and warnings
use Carp;
use Cwd;
use version; our $VERSION = qv('0.01');

use FindBin qw($Bin);
use lib $Bin;
use RemoteBackup::Configuration;
use RemoteBackup::Database;
use RemoteBackup::Machine;

=head1 NAME

RemoteBackup - Backup information from remote Linux machine. 


=head1 VERSION

This document describes RemoteBackup version 0.0.1

=head1 SYNOPSIS

 use RemoteBackup;

 my $backup = RemoteBackup->new('config_xml' => './config/machine1.xml');

 $backup->backup_all();

=head1 DESCRIPTION

Backup directories and databases on remote Linux machine.

For testing, place the id_rsa file in your ~/.ssh/ direcotry.

See the configuration file ./config/example.xml for how to
set up machines, directories, and databases to be backed up.

=head1 INTERFACE

Object fields:

=over 4

=cut

=item B<config_xml> Full path to and name of config XML file.
=cut

has 'config_xml' => (is => 'rw', isa => 'Str');


=item B<config> Configuration object - created from XML using Configuration module.
=cut

has 'config' => (is => 'rw', isa => 'RemoteBackup::Configuration', lazy => 1, default => sub {
		my $self = shift;
		my $config = RemoteBackup::Configuration->new('file' => $self->config_xml);
		$config->read_configuration();
		return $config;
	}
);

=back

=pod

Object methods:

=over 4

=cut

sub backup_all {
	my $self = shift;

=item B<backup_all> Backup all machines and databases defined in the configuration XML.

 Input: None

 Returns: Number of machines backed up

 Side Effect: All directories and databases on all machines backed up.

=cut

 # Loop over the machines in the configuration and back them up
 my $count = 0;
 while ( my $machine = $self->config->get_next_machine() ) {
	 $machine->backup();
	 # Loop over the datbases on each machine and back them up
	 while ( my $database = $self->config->get_next_database() ) {
		 $database->backup($machine);
	 }
	 $count++;
	}

	return $count;

}


=back
=cut


__PACKAGE__->meta->make_immutable;

1; # Magic true value required at end of module

=head1 CONFIGURATION AND ENVIRONMENT

You must set up ssh login keys for each remote machine you
wish to backup non-interactively.

For more information on how to do this see Hack #66 in Linux Server Hacks
http://oreilly.com/pub/h/66

RemoteBackup requires no configuration files or environment variables.

=head1 DEPENDENCIES

None.

=head1 INCOMPATIBILITIES


None reported.


=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Limitations: Currently limited to backing up remote Linux machines.


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
