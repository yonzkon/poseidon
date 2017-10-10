package server;

use strict;
use Socket;
use loop_socket;
use base 'socket_raw';

sub new {
    my $class = shift;
    my $self = socket_raw->new(@_);
    $self->{'connection'} = undef;
    bless($self, $class);
    return $self;
};

sub create_server {
    my ($port, $ipaddr) = @_;

    socket(my $fh, AF_INET, SOCK_STREAM, 0) ||
	return undef;
    bind($fh, sockaddr_in($port, $ipaddr)) ||
	(close($fh) && return undef);
    listen($fh, 100) ||
	(close($fh) && return undef);

    my $server = new server($fh);
    loop_socket::add($server);
    return $server;
}

1;
