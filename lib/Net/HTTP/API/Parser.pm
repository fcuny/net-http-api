package Net::HTTP::API::Parser;

# ABSTRACT: base class for all Net::HTTP::API::Parser

use Moose;

has format_options => (
    is         => 'rw',
    isa        => 'HashRef',
    auto_deref => 1,
);

sub encode {die "must be implemented"}
sub decode {die "must be implemented"}

1;

=head1 SYNOPSIS

=head1 DESCRIPTION

