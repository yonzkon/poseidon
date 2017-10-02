#!/usr/bin/env perl

BEGIN{push(@INC, "./net")};

use server;
use loop_socket;
use Socket;

STDOUT->autoflush(1);
STDERR->autoflush(1);

sub on_packet {
    my $session = shift;

    my ($port, $ipaddr) = sockaddr_in(getpeername($session->filehandle));
    printf("%s:%d (%d): %s\n", inet_ntoa($ipaddr), $port,
           fileno($session->filehandle), $session->{'rbuf'});

    $session->{'rbuf'} = '';
    $session->{'wbuf'} = "welcome to perl\n";
}

sub on_connection {
    my $client = shift;
    $client->{'packet'} = \&on_packet;
}

my $server = server::create_server('5964', INADDR_ANY);
$server->{'connection'} = \&on_connection;

while (1) {
    loop_socket::loop(0.5);
}
