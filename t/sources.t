use strict;
use warnings;
use Test::More;
use IO::File;
use Dotenv;

my %expected = (
    Barbapapa   => 'pink',
    Barbabright => 'blue',
    Barbalib    => 'orange',
);

open my $fh, '<:utf8', 't/env/barb.env';

my @sources = (
    \ << 'EOT',
Barbabright = blue
Barbalib    =orange
export Barbapapa = pink
EOT
    [ 'Barbabright=blue', "Barbalib = orange\n   Barbapapa = pink    " ],
    \%expected,
    $fh,
    do {
        my $io = IO::File->new( 't/env/barb.env', 'r' );
        $io->binmode(':utf8');
        $io;
    },
);

for my $source (@sources) {
    my $got = Dotenv->parse($source);
    is_deeply( $got, \%expected, ref $source );
}

done_testing;

