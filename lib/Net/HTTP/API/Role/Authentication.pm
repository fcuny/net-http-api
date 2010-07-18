package Net::HTTP::API::Role::Authentication;

# ABSTRACT: Add authentication informations to request header

use Moose::Role;

has api_username => (
    is        => 'rw',
    isa       => 'Str',
    predicate => 'has_api_username',
);

has api_password => (
    is        => 'rw',
    isa       => 'Str',
    predicate => 'has_api_password',
);

# ugly :(
after BUILDALL => sub {
    my $self = shift;

    for (qw/api_username api_password/) {
        my $predicate = 'has_' . $_;
        my $value     = $self->meta->get_api_option($_);
        $self->$_($value) if $value && !$self->$predicate;
    }

    if (   $self->meta->get_api_option('authentication')
        || $self->meta->get_api_option('authentication_method'))
    {
        my $auth_method = $self->meta->get_api_option('authentication_method');
        if ($auth_method) {
            $self->api_useragent->add_handler(
                request_prepare => sub { $self->$auth_method(@_) });
        }
        else {
            if ($self->has_api_username && $self->has_api_password) {
                $self->api_useragent->add_handler(
                    request_prepare => sub {
                        my $req = shift;
                        $req->headers->authorization_basic($self->api_username,
                            $self->api_password);
                    }
                );
            }
        }
    }
};

1;

=head1 SYNOPSIS

=head1 DESCRIPTION

=head2 ATTRIBUTES

=over 4

=item B<api_password>

=item B<api_username>

=back
