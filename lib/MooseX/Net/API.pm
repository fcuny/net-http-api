package MooseX::Net::API;

use Moose;
use Moose::Exporter;

our $VERSION = '0.11';

Moose::Exporter->setup_import_methods(
    with_meta => [qw/net_api_method net_api_declare/],
    also      => [qw/Moose/]
);

sub net_api_method {
    my $meta = shift;
    my $name = shift;
    $meta->add_net_api_method($name, @_);
}

sub net_api_declare {
    my $meta = shift;
    my $name = shift;
    $meta->add_net_api_declare($name, @_);
}

sub init_meta {
    my ($class, %options) = @_;

    my $for = $options{for_class};
    Moose->init_meta(%options);

    my $meta = Moose::Util::MetaRole::apply_metaroles(
        for_class       => $for,
        metaclass_roles => ['MooseX::Net::API::Meta::Class'],
    );

    Moose::Util::MetaRole::apply_base_class_roles(
        for   => $for,
        roles => [
            qw/
              MooseX::Net::API::Role::UserAgent
              MooseX::Net::API::Role::Format
              MooseX::Net::API::Role::Authentication
              MooseX::Net::API::Role::Serialization
              MooseX::Net::API::Role::Request
              /
        ],
    );

    $meta;
}

1;

__END__

=head1 NAME

MooseX::Net::API - Easily create client for net API

=head1 SYNOPSIS

    package My::Net::API;
    use MooseX::Net::API;

    # we declare an API, the base_url is http://exemple.com/api
    # the format is json and it will be append to the query
    # You can set api_base_url later, calling $obj->api_base_url('http://..')
    net_api_declare my_api => (
        api_base_url    => 'http://exemple.com/api',
        api_format      => 'json',
        api_format_mode => 'append',
    );

    # declaring a users method
    # calling $obj->users will call http://exemple.com/api/users?country=france
    net_api_method users => (
        description => 'this get a list of users',
        method      => 'GET',
        path        => '/users/',
        params      => [qw/country/],
    );

    # you can create your own useragent (it must be a LWP::UserAgent object)
    net_api_declare my_api => (
        ...
        useragent => sub {
            my $ua = LWP::UserAgent->new;
            $ua->agent('MyUberAgent/0.23');
            return $ua
        },
        ...
    );

    # if the API require authentification, the module will handle basic
    # authentication for you
    net_api_declare my_api => (
        ...
        authentication => 1,
        ...
    );

    # if the authentication is more complex, you can delegate to your own method

    1;

    my $obj = My::Net::API->new();
    $obj->api_base_url('http://...');
    $obj->foo(user => $user);

=head1 DESCRIPTION

MooseX::Net::API is a module to help to easily create a client for a web API.
This module is heavily inspired by what L<Net::Twitter> does.

B<THIS MODULE IS IN ITS BETA QUALITY. THE API MAY CHANGE IN THE FUTURE>

=head2 METHODS

=over 4

=item B<net_api_declare>

    net_api_declare backtype => (
        base_url    => 'http://api....',
        format      => 'json',
        format_mode => 'append',
    );

=over 2

=item B<api_base_url>

The base url for all the API's calls. This will add an B<api_base_url> attribut to your class. Can be set at the object creation or before calling an API method. If no api_base_url is defined, the method will die.

=item B<api_format> (required, must be either xml, json or yaml)

The format for the API's calls. This will add an B<api_format> attribut to your class.

=item B<api_format_mode> (required, must be 'append' or 'content-type')

How the format is handled. B<append> will add B<.json> to the query, B<content-type> will add the content-type information to the header of the request.

=item B<useragent> (optional, by default it's a LWP::UserAgent object)

    useragent => sub {
        my $ua = LWP::UserAgent->new;
        $ua->agent( "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.1) Gecko/20061204 Firefox/2.0.0.1");
        return $ua;
    }

=item B<authentication> (optional)

This is a boolean to tell if we must authenticate to use this API.

=item B<authentication_method> (optional)

The default authentication method only set an authorization header using the Basic Authentication Scheme. You can write your own authentication method:

  net_api_declare foo => (
    ...
    authentication_method => 'my_auth_method',
    ...
  );

  sub my_auth_method {
    my ($self, $req) = @_; #$req is an HTTP::Request object
    ...
    return $req;
  }

=back

=item B<net_api_method>

=over 2

=item B<description> [string]

description of the method (this is a documentation)

=item B<method> [string]

HTTP method (GET, POST, PUT, DELETE)

=item B<path> [string]

path of the query.

If you defined your path and params like this

    net_api_method user_comments => (
      ...
      path => '/user/$user/list/$date/',
      params => [qw/user date foo bar/],
      ...
    );

and you call

    $obj->user_comments(user => 'franck', date => 'today', foo => 1, bar => 2);

the url generetad will look like

    /user/franck/list/today/?foo=1&bar=2

=item B<params> [arrayref]

list of params.

=item B<required> [arrayref]

list of required params.

=item B<authentication> (optional)

should we do an authenticated call

=item B<params_in_url> (optional)

When you do a post, the content may have to be sent as arguments in the url, and not as content in the header.

=back

=back

=head1 AUTHOR

franck cuny E<lt>franck@lumberjaph.netE<gt>

=head1 SEE ALSO

=head1 LICENSE

Copyright 2009 by Linkfluence

http://linkfluence.net

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

