package query_server;

#use strict;
use Socket;

use server;
use loop_socket;
use ragnarok_server;
use Messages qw(serialize unserialize);

our $server;
our $run_flags = 1;

our %query_table = ();

sub ragnarok_pre_loop {
    my $ragnarok_client;

    foreach my $item (values %loop_socket::socket_table) {
	if ($item->{'parent'} and $item->{'parent'} == $ragnarok_server::server) {
	    $ragnarok_client = $item;
	    last;
	}
    }

    foreach my $item (values %query_table) {
	if (!$$item{'time'}) {
	    $$item{'time'} = time;
	    $$item{'ragnarok_client'} = $ragnarok_client;
	    $ragnarok_client->{'wbuf'} .= $$item{'request_data'};
	    last;
	}
    }
}

sub ragnarok_pre_on_packet {
    my ($ragnarok_client, $switch) = @_;

    return unless $switch eq '09D0';

    while (my ($key, $value) = each %query_table) {
	next if !$$value{'time'};
	next if $$value{'ragnarok_client'} != $ragnarok_client;

	$$value{'response_data'} = $ragnarok_client->{'rbuf'};
	my %args;
	$args{packet} = $$value{'response_data'};
	$$value{'session'}->{'wbuf'} = serialize("Poseidon Reply", \%args);
	printf("Poseidon Reply: %s => %s\n",
	       unpack('H*', $$value{'request_data'}),
	       unpack('H*', $$value{'response_data'}));
	delete $query_table{$key};
	last;
    }
}

sub on_packet {
    my $session = shift;

    my $ID;
    my $args = unserialize($session->{'rbuf'}, $ID);
    my $switch = sprintf("%.4X", unpack("v", $args->{'packet'}));

    if ($switch eq '09CF') {
	$query_table{$session} = {
	    time => 0,
	    session => $session,
	    ragnarok_client => undef,
	    request_data => $args->{'packet'},
	    response_data => undef,
	};
	printf("Poseidon Query: %s\n", unpack("H*", $args->{'packet'}));
    }

    $session->{'rbuf'} = '';
}

sub on_connection {
    my $client = shift;
    $client->{'packet'} = \&on_packet;
}

sub loop {
    my $timeout = 0.2;
    $timeout = $_[0] if $_[0];
    loop_socket::loop($timeout);
}

sub run {
    loop while ($run_flags);
}

sub init {
    $server = server::create_server('24390', INADDR_ANY);
    $server->{'connection'} = \&on_connection;

    $ragnarok_server::pre_loop = \&ragnarok_pre_loop;
    $ragnarok_server::pre_on_packet = \&ragnarok_pre_on_packet;
}

1;
