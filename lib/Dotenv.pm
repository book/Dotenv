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
