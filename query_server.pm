package query_server;

use strict;
use Socket;

use server;
use loop_socket;
use ragnarok_server;
use Messages qw(serialize unserialize);

our $server;
our $run_flags = 1;

our @query_table = ();

sub ragnarok_pre_loop {
    my $ragnarok_client;

    foreach my $item (values %loop_socket::socket_table) {
	if ($item->{'parent'} and $item->{'parent'} == $ragnarok_server::server) {
	    $ragnarok_client = $item;
	    last;
	}
    }

    foreach my $item (@query_table) {
	if ($$item[2]) {
	    $$item[2] = 0;
	    $$item[3] = $ragnarok_client;
	    $ragnarok_client->{'wbuf'} .= $$item[1];
	    last;
	}
    }
}

sub ragnarok_pre_on_packet {
    my ($ragnarok_client, $switch) = @_;

    return unless $switch eq '09D0';

    foreach my $item (@query_table) {
	if ($$item[3] == $ragnarok_client and !$$item[4]) {
	    $$item[4] = $ragnarok_client->{'rbuf'};
	    my %args;
	    $args{packet} = $$item[4];
	    $$item[0]->{'wbuf'} = serialize("Poseidon Reply", \%args);
	    printf("Poseidon Reply: %s => %s\n",
		   unpack('H*', $$item[1]), unpack('H*', $$item[4]));
	    last;
	}
    }
}

sub on_packet {
    my $session = shift;

    my $ID;
    my $args = unserialize($session->{'rbuf'}, $ID);
    my $switch = sprintf("%.4X", unpack("v", $args->{'packet'}));

    if ($switch eq '09CF') {
	push(@query_table, [$session, $args->{'packet'}, 1, undef, '']);
	printf("Poseidon Query: %s\n", unpack("H*", $args->{'packet'}));
    }

    $session->{'rbuf'} = '';
}

sub on_connection {
    my $client = shift;
    $client->{'packet'} = \&on_packet;
}

sub loop {
    my $timeout = 0.5;
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
