package Net::HTTP::API::Meta::Class;

# ABSTRACT: metaclass for all API client

use Moose::Role;

with qw/
    Net::HTTP::API::Meta::Method::APIMethod
    Net::HTTP::API::Meta::Method::APIDeclare
    /;

1;

__END__

=head1 SYNOPSIS

=head1 DESCRIPTION
