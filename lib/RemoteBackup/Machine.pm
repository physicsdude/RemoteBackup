package RemoteBackup::Machine;
use Moose; # automatically turns on strict and warnings
use Carp;
use Cwd;
use version; our $VERSION = qv('0.01');

=head1 NAME

RemoteBackup::Machine - Store meta information and methods for remote machines.

=head1 VERSION

This document describes Machine version 0.0.1

=head1 SYNOPSIS

 my $machine = RemoteBackup::Machine->new(
		    'user' => $user,
		    'host' => $host,
		    'directories' => [ 'dir1', 'dir2' ],
		    );

 $machine->backup();

=head1 DESCRIPTION

Store meta information and methods for backing up remote machines.

=head1 INTERFACE

Object fields:

=over 4

=cut

=item B<user> User name to login to remote machine (must have ssh keys set up).
=cut

has 'user' => (
	is      => 'rw',
	isa     => 'Str',
	default => 'root'
);

=item B<host> Host name or ip address
=cut

has 'host' => (
	is  => 'rw',
	isa => 'Str'
);

=item B<directories> Reference to array of directories to backup.
=cut

has 'directories' => (
	is       => 'rw',
	isa      => 'ArrayRef',
	required => 1
);

=item B<local_directory> Directory to store backup under
=cut

has 'local_directory' => (
	is       => 'rw',
	isa      => 'Str',
	required => 1
);

=item B<backup_directory> Directory to back up to (automatically add host/ip to local_directory if value not specified)
=cut

# Use 'lazy' to indicate do not run the 'default' sub until this method is called
has 'backup_directory' => (
	is      => 'rw',
	isa     => 'Str',
	lazy    => 1,
	default => sub {
		my $self = shift;
		my $dir  = $self->local_directory . '/' . $self->host;
		if (not -d $dir) {
			my $t_dir = getcwd();
			chdir $self->local_directory or croak "Couldn't chdir: $!";
			mkdir $self->host            or croak "Couldn't make directory: $!";
			chdir $t_dir                 or croak "Couldn't chdir: $!";
		}
		return $dir;
		}
);

=back

=pod

Object methods:

=over 4

=cut

sub backup {
	my $self = shift;

=item B<backup> Backup the machine

 Input: None

 Returns: Number of directories backed up

 Side Effect: Directories are backed up

=cut

	my $count = 0;
	foreach my $dir (@{ $self->directories }) {

		$dir =~ s{/$}{}; # Want to sync dir name also

		print "Backing up $dir\n";

		my $cmd = '/usr/bin/rsync -ae ssh ' . $self->user . '@' . $self->host . ':"' . $dir . '" ' . $self->backup_directory;
		if (system($cmd)) {
			croak "Failed to execute: '$cmd': $!";
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


=head1 DEPENDENCIES

rsync command

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
