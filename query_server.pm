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

sub get_ragnarok_client {
    foreach my $item (values %loop_socket::socket_table) {
	if (!$item->eof and !$item->{'charid'} and $item->{'parent'} and
	    $item->{'parent'} == $ragnarok_server::server) {
	    $item->{'charid'} = $_[0];
	    return $item;
	}
    }
    return undef;
}

sub put_ragnarok_client {
    delete $_[0]->{'charid'} if $_[0]->{'charid'};
}

sub ragnarok_pre_on_packet {
    my ($ragnarok_client, $switch) = @_;

    return unless $switch eq '09D0';

    while (my ($key, $value) = each %query_table) {
	next if !$value->{'requested'};
	next if $value->{'ragnarok_client'} != $ragnarok_client;

	$value->{'response_data'} = $ragnarok_client->{'rbuf'};
	my %args;
	$args{packet} = $value->{'response_data'};
	$value->{'session'}->{'wbuf'} = serialize("Poseidon Reply", \%args);
	printf("Poseidon Reply(%s): %s => %s\n", $key,
	       unpack('H*', $value->{'request_data'}),
	       unpack('H*', $value->{'response_data'}));
	last;
    }
}

sub ragnarok_pre_loop {
    while (my ($key, $value) = each %query_table) {
	# put ragnarok client if inactived
	if ($value->{'last_query_time'} + 1800 < time) {
	    if ($value->{'ragnarok_client'}) {
		put_ragnarok_client($value->{'ragnarok_client'});
		$value->{'ragnarok_client'} = undef;
	    }
	    delete $query_table{$key};
	    next;
	}

	# get ragnarok client if actived
	if (!$value->{'ragnarok_client'} or $value->{'ragnarok_client'}->eof) {
	    my $tmp = get_ragnarok_client($key);
	    if (!$tmp) {
		$value->{'last_query_time'} = 0;
		$value->{'session'}->close;
		print "no free ragnarok-client left!\n";
		next;
	    } else {
		$value->{'ragnarok_client'} = $tmp;
	    }
	}

	unless ($value->{'requested'}) {
	    $value->{'requested'} = 1;
	    $value->{'ragnarok_client'}->{'wbuf'} .= $value->{'request_data'};
	}
    }
}

sub on_packet {
    my $session = shift;

    my $ID;
    my $args = unserialize($session->{'rbuf'}, $ID);
    my $switch = sprintf("%.4X", unpack("v", $args->{'packet'}));

    if ($switch eq '09CF' and $args->{'charid'}) {
	$charid = unpack('H*', $args->{'charid'});

	unless (exists $query_table{"$charid"}) {
	    $query_table{"$charid"} = {
		last_query_time => time,
		session => $session,
		ragnarok_client => undef,
		requested => 0,
		request_data => $args->{'packet'},
		response_data => undef,
	    };
	} else {
	    my $query = $query_table{"$charid"};
	    $query->{'last_query_time'} = time;
	    $query->{'session'} = $session;
	    $query->{'requested'} = 0;
	    $query->{'request_data'} = $args->{'packet'};
	}

	printf("Poseidon Query(%s): %s\n", $charid,
	       unpack("H*", $args->{'packet'}));
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
