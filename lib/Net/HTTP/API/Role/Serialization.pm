package Net::HTTP::API::Role::Serialization;

# ABSTRACT: do (de)serialization

use 5.010;

use Try::Tiny;
use Moose::Role;
use Net::HTTP::API::Error;

has serializers => (
    traits     => ['Hash'],
    is         => 'rw',
    isa        => 'HashRef[Net::HTTP::API::Parser]',
    default    => sub { {} },
    auto_deref => 1,
    handles    => {
        _add_serializer => 'set',
        _get_serializer => 'get',
    },
);

sub get_content {
    my ($self, $result) = @_;

    return undef unless $result->content;

    my $content_type = $self->api_format // $result->header('Content-Type');
    $content_type =~ s/(;.+)$//;

    my $content;
    if ($result->is_success && $result->code != 204) {
        my @deserialize_order = ($content_type, $self->api_format);
        $content = $self->deserialize($result->content, \@deserialize_order);

        if (!$content) {
            die Net::HTTP::API::Error->new(
                reason     => "can't deserialize content",
                http_error => $result,
            );
        }
    }
    $content;
}

sub deserialize {
    my ($self, $content, $list_of_formats) = @_;

    foreach my $format (@$list_of_formats) {
        my $s = $self->_get_serializer($format)
          || $self->_load_serializer($format);
        next unless $s;
        my $result;
        try { $result = $s->decode($content) };
        return $result if $result;
    }
}

sub serialize {
    my ($self, $content) = @_;
    my $s = $self->_get_serializer($self->api_format)
      || $self->_load_serializer();
    my $result = try { $s->encode($content) };
    return $result if $result;
}

sub _load_serializer {
    my $self   = shift;
    my $format = shift || $self->api_format;
    my $parser = "Net::HTTP::API::Parser::" . uc($format);
    if (Class::MOP::load_class($parser)) {
        my $o = $parser->new(format_options => $self->api_format_options);
        $self->_add_serializer($format => $o);
        return $o;
    }
}

1;

__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

=head2 ATTRIBUTES

=over 4

=item B<serializers>

=back

=head2 METHODS

=over 4

=item B<get_content>

=item B<serialize>

=item B<deserialize>

=back
