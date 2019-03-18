package Dotenv;

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

sub load {
    my ( $class, @sources ) = @_;
    my %env;
    %env = %ENV if !defined wantarray;

    for my $source (@sources) {
        Carp::croak "Can't handle an unitialized value"
          if !defined $source;
        my %kv;
	my $ref = ref $source;
        if ( $ref eq '' ) {
            %kv = $parse->( $source, \%env );
        }
        elsif ( $ref eq 'HASH' ) {    # bare hash ref
            %kv = %$source;
        }
        elsif ( $ref eq 'SCALAR' ) {
            %kv = $parse->( $$source, \%env );
        }
        elsif ( $ref eq 'GLOB' ) {
            local $/;
            %kv = $parse->( scalar <$source>, \%env );
            close $content;
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

    return !defined wantarray
      ? %ENV = %env    # replace %ENV in void context
      : %env;          # return the parsed pairs otherwise
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
    Dotenv->load(@env_files);

    # add some local stuff to %ENV
    # (.env is the default if there are no arguments)
    Dotenv->load( \%my_env );

    # return the key/value pairs read in the file,
    # but do not set %ENV
    my %env = Dotenv->load('app.env');

    # dynamically modify %ENV
    local %ENV = Dotenv->load( 'test.env', \%ENV );

    # order of arguments matters, so this might yield different results
    local %ENV = Dotenv->load( \%ENV, 'test.env' );

=cut
