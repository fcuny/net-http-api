package MooseX::Net::API;

use Moose::Exporter;
use Carp;
use Try::Tiny;

our $VERSION = '0.01';

our $content_type = {
    'json' => 'application/json',
    'yaml' => 'text/x-yaml',
    'xml'  => 'text/xml',
};

Moose::Exporter->setup_import_methods(
    with_caller => [qw/net_api_method format_query require_authentication/], );

sub format_query {
    my ( $caller, $name, %options ) = @_;

    Moose::Meta::Class->initialize($caller)->add_method(
        _format => sub {
            { format => $_[1]->$name, mode => $options{mode} }
        }
    );
}

my $do_authentication;
sub require_authentication { $do_authentication = $_[1] }

sub net_api_method {
    my $caller  = shift;
    my $name    = shift;
    my %options = @_;

    my $class = Moose::Meta::Class->initialize($caller);

    for (qw/api_base_url format/) {
        if ( !$caller->meta->has_attribute($_) ) {
            croak "attribut $_ is missing";
        }
    }

    if ( !$class->meta->has_attribute('useragent') ) {
        _init_useragent($class);
    }

    my $code;
    if ( !$options{code} ) {
        $code = sub {
            my $self = shift;
            my %args = @_;

            if ($options{path} =~ /\$(\w+)/) {
                my $match = $1;
                if (my $value = delete $args{$match}) {
                    $options{path} =~ s/\$$match/$value/;
                }
            }
            my $url = $self->api_base_url.$options{path};

            my $format = $caller->_format($self);
            $url .= "." . $self->format if ( $format->{mode} eq 'append' );

            my $req;
            my $uri = URI->new($url);

            my $method = $options{method};
            if ( $method =~ /^(?:GET|DELETE)$/ ) {
                $uri->query_form(%args);
                $req = HTTP::Request->new($method => $uri);
            }
            elsif ( $method =~ /^(?:POST|PUT)$/ ) {
                $req = HTTP::Request->new($method => $uri);
            }
            else {
                croak "$method is not defined";
            }

            $req->header(
                'Content-Type' => $content_type->{ $format->{format} } )
                if $format->{mode} eq 'content-type';
            #return 1;
            my $res = $self->useragent->request($req);
            return $res->content;
        };
    }
    else {
        $code = delete $options{code};
    }
    $class->add_method(
        $name,
        MooseX::Net::API::Meta::Method->new(
            name         => $name,
            package_name => $caller,
            body         => $code,
            %options,
        ),
    );
}

sub _request {
    my $class = shift;
}

sub _init_useragent {
    my $class = shift;
    try {
        require LWP::UserAgent;
    }
    catch {
        croak "no useragent defined and LWP::UserAgent is not available";
    };
    my $ua = LWP::UserAgent->new();
    $ua->env_proxy;

    $class->add_attribute(
        'useragent',
        is      => 'rw',
        isa     => 'LWP::UserAgent',
        lazy    => 1,
        default => sub {$ua},
    );
}

package MooseX::Net::API::Meta::Method;

use Moose;
extends 'Moose::Meta::Method';
use Carp;

has description => ( is => 'ro', isa => 'Str' );
has path        => ( is => 'ro', isa => 'Str', required => 1 );
has method      => ( is => 'ro', isa => 'Str', required => 1 );
has params      => ( is => 'ro', isa => 'ArrayRef', required => 0 );
has required    => ( is => 'ro', isa => 'ArrayRef', required => 0 );

sub new {
    my $class = shift;
    my %args  = @_;
    $class->SUPER::wrap(@_);

}

1;
__END__

=head1 NAME

MooseX::Net::API - Easily create client for net API

=head1 SYNOPSIS

  use MooseX::Net::API;

  net_api_method => (
    description => 'this get foo',
    method      => 'GET',
    path        => '/foo/',
    arguments   => qw[/user group/],
  );

=head1 DESCRIPTION

MooseX::Net::API is

=head1 AUTHOR

franck cuny E<lt>franck.cuny@rtgi.frE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
