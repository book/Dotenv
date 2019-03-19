package Dotenv;

use strict;
use warnings;

use Carp       ();
use Path::Tiny ();

my $parse = sub {
    my ( $string, $env ) = @_;
    my %kv;
    for my $line ( split /$/, $string ) {
        chomp($line);
        my ( $k, $v ) = split /\s*=\s*/, $line, 2;

        # TODO: munging of "" '' $vars

        $kv{$k} = $v;
    }
    return %kv;
};

sub parse {
    my ( $package, @sources ) = @_;
    my %env;

    for my $source (@sources) {
        Carp::croak "Can't handle an unitialized value"
          if !defined $source;

        my %kv;
        my $ref = ref $source;
        if ( $ref eq '' ) {
            %kv = $parse->( Path::Tiny->new($source)->slurp_utf8, \%env );
        }
        elsif ( $ref eq 'HASH' ) {    # bare hash ref
            %kv = %$source;
        }
        elsif ( $ref eq 'ARRAY' ) {
            %kv = $parse->( join( "\n", @$source ), \%env );
        }
        elsif ( $ref eq 'SCALAR' ) {
            %kv = $parse->( $$source, \%env );
        }
        elsif ( $ref eq 'GLOB' ) {
            local $/;
            %kv = $parse->( scalar <$source>, \%env );
            close $source;
        }
        elsif ( eval { $source->can('getline') } ) {
            local $/;
            %kv = $parse->( scalar $source->getline, \%env );
            $source->close;
        }
        else {
            Carp::croak "Don't know how to handle '$source'";
        }

        # don't overwrite anything that already exists
        %env = ( %kv, %env );
    }

    return %env;
}

sub load {
    my ( $package, @sources ) = @_;
    %ENV = $package->parse( \%ENV, @sources );
}

'.env';

__END__

=pod

=head1 NAME

Dotenv - Support for C<dotenv> in Perl

=head1 SYNOPSIS

    # basic operation
    use Dotenv;      # exports nothing
    Dotenv->load;    # merge the content of .env in %ENV

    # the source for environment variables can be
    # a file, a filehandle, a hash reference
    # they are loaded in order in %ENV without modifying existing values
    Dotenv->load(@sources);

    # add some local stuff to %ENV
    # (.env is the default only if there are no arguments)
    Dotenv->load( \%my_env );

    # return the key/value pairs read in the file,
    # but do not set %ENV
    my %env = Dotenv->parse('app.env');

    # dynamically add to %ENV
    local %ENV = Dotenv->parse( \%ENV, 'test.env' );

    # order of arguments matters, so this might yield different results
    local %ENV = Dotenv->parse( 'test.env', \%ENV );

=cut
