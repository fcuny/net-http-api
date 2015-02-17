package Net::HTTP::API::Parser::YAML;

# ABSTRACT: Parse YAML

use YAML::Syck;
use Moose;
extends 'Net::HTTP::API::Parser';

sub encode {
    my ($self, $content) = @_;
    return Dump($content);
}

sub decode {
    my ($self, $content) = @_;
    return Load($content);
}

1;

__END__

=head1 SYNOPSIS

=head1 DESCRIPTION
