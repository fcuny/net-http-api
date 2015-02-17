package Net::HTTP::API::Parser::XML;

# ABSTRACT: Parse XML result

use XML::Simple;
use Moose;
extends 'Net::HTTP::API::Parser';

has _xml_parser => (
    is      => 'rw',
    isa     => 'XML::Simple',
    lazy    => 1,
    default => sub { XML::SImple->new(ForceArray => 0) }
);

sub encode {
    my ($self, $content) = @_;
    return $self->_xml_parser->XMLin($content);
}

sub decode {
    my ($self, $content) = @_;
    return $self->_xml_parser->XMLout($content);
}

1;

__END__

=head1 SYNOPSIS

=head1 DESCRIPTION
