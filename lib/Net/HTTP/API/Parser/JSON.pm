package Net::HTTP::API::Parser::JSON;

# ABSTRACT: Parse JSON

use JSON;
use Moose;
extends 'Net::HTTP::API::Parser';

sub encode {
    my ($self, $content) = @_;
    JSON::to_json($content, $self->format_options);
}

sub decode {
    my ($self, $content) = @_;
    JSON::from_json($content, $self->format_options);
}

1;

__END__

=head1 SYNOPSIS

=head1 DESCRIPTION
