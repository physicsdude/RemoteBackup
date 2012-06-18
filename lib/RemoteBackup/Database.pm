package RemoteBackup::Database;
use Moose; # automatically turns on strict and warnings
use Carp;
use Cwd;
use version; our $VERSION = qv('0.01');

=head1 NAME

RemoteBackup::Database - Store information about and backup remote MySQL databases.

=head1 VERSION

This document describes RemoteBackup version 0.0.1


=head1 SYNOPSIS

 ...

 my $db_backup = RemoteBackup::Database->new(
		    'user' => $user,
		    'pass' => $pass,
		    'name' => $name,
		    'machine' => $machine,
		    );

 $db_backup->backup();

 ...

=head1 DESCRIPTION

Store information about and backup remote databases.

=head1 INTERFACE

Object fields:

=over 4

=cut

=item B<user> Database username.
=cut

has 'user' => (
	is       => 'rw',
	isa      => 'Str',
	required => 1
);

=item B<pass> Database password.
=cut

has 'pass' => (
	is       => 'rw',
	isa      => 'Str',
	required => 1
);

=item B<name> Name of the database
=cut

has 'name' => (
	is       => 'rw',
	isa      => 'Str',
	required => 1
);

=item B<machine> Reference to a Machine object
=cut

has 'machine' => (
	is       => 'rw',
	isa      => 'RemoteBackup::Machine',
	required => 1
);

=back

=pod

Object methods:

=over 4

=cut

sub backup {
	my $self    = shift;
	my $machine = shift;

=item B<backup> Backup database

 Input: Database.pm object

 Returns: Size of gzipped backup file

 Side Effect: Database on remote machine backed up.

=cut

	my $db_backup_dir = $machine->backup_directory . "/db_backup/";
	if (not -d $db_backup_dir) {
		my $t_dir = getcwd();
		chdir $machine->backup_directory or croak "Couldn't chdir: $!";
		mkdir 'db_backup'                or croak "Couldn't make directory: $!";
		chdir $t_dir                     or croak "Couldn't chdir: $!";
	}
	my $sqlfile = $db_backup_dir . '/' . $self->name . '.' . time . ".gz";
	my $cmd     = "mysqldump --opt -u" . $self->user . " -p" . $self->pass . " " . $self->name;
	my $run     = 'ssh ' . $machine->user . '@' . $machine->host . " '$cmd' | gzip -9 > $sqlfile";
	my $out     = `$run`;
	if (0 != $?) {
		print "Output: $out\n";
		croak "Error executing '$run': $!";
	}

	return -s $sqlfile;

}

=back
=cut

__PACKAGE__->meta->make_immutable;

1; # Magic true value required at end of module

=head1 CONFIGURATION AND ENVIRONMENT


=head1 DEPENDENCIES

RemoteBackup::Machine.pm

=head1 INCOMPATIBILITIES

None reported.


=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Limitations: Currently limited to backing up MySQL databases on Linux machines.


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
