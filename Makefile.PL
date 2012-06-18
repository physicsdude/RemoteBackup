
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME            => 'RemoteBackup',
    AUTHOR          => 'Bryan Gmyrek <bryangmyrek@gmail.com>',
    VERSION_FROM    => 'lib/RemoteBackup.pm',
    ABSTRACT_FROM   => 'lib/RemoteBackup.pm',
    PL_FILES        => {},
    PREREQ_PM    => {
        'Test::More'    => 0,
        'version'       => 0,
    },
    dist            => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean           => { FILES => 't/testdata/example.com*' },
);
