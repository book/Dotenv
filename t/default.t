use strict;
use warnings;
use Test::More;
use Dotenv;

chdir 't/env' or diag "Can't chdir to t/env: $!";

my $env = Dotenv->parse;
is_deeply( $env, { DOTENV => 'true' }, 'parse read .env by default' );

$env = { DOTENV => 'true', local %ENV = %ENV };
Dotenv->load;
is_deeply( \%ENV, $env, 'load read .env by default' );

chdir '..' or diag "Can't chdir back to t: $!";
Dotenv->load;

pass 'load survives if no default .env file exists';

done_testing;

