package loop_socket;

use strict;
use Socket;
use socket_raw;

our %socket_table;

sub add {
    my $socket = shift;
    my $fd = fileno($socket->filehandle);
    $socket_table{$fd} = $socket;

    if (!$socket->isa('server')) {
        my $sockaddr = getpeername($socket->filehandle);
        if ($sockaddr) {
            my ($port, $ipaddr) = sockaddr_in($sockaddr);
            printf("accept client(%d) %s:%d\n", $fd, inet_ntoa($ipaddr), $port);
        } else {
            printf("accept cleint(%d) failed to get remote ipaddr!\n");
        }
    }
};

sub remove {
    my $socket = shift;
    my $fd = fileno($socket->filehandle);
    delete $socket_table{"$fd"};

    if (!$socket->isa('server')) {
        my $sockaddr = getpeername($socket->filehandle);
        if ($sockaddr) {
            my ($port, $ipaddr) = sockaddr_in($sockaddr);
            printf("close client(%d) %s:%d\n", $fd, inet_ntoa($ipaddr), $port);
        } else {
            printf("close cleint(%d) failed to get remote ipaddr!\n");
        }
    }
};

sub loop {
    my $timeout = shift;
    my $rin = my $win = my $ein = '';

    foreach my $item (values %socket_table) {
        vec($rin, fileno($item->filehandle), 1) = 1;
    }
    $win = $rin;
    $ein = $rin;

    my $nfound = select(my $rout = $rin, undef, undef, $timeout);
    die("select failed: $!") if $nfound == -1;
    foreach my $item (values %socket_table) {
        last if !$nfound;
        if (vec($rout, fileno($item->filehandle), 1)) {
            $nfound--;

            if ($item->isa('server') && accept(my $fh, $item->filehandle)) {
                my $client = new socket_raw($fh, $item);
                add($client);
                if ($item->{'connection'}) {
                    $item->{'connection'}->($client);
                }
            } elsif ($item->isa('socket_raw')) {
                $item->{'tick'} = time;
                recv($item->filehandle, my $buffer, 1024, 0);
                if ($buffer) {
                    $item->{'rbuf'} .= $buffer;
                    if ($item->{'packet'}) {
                        $item->{'packet'}->($item);
                    }
                } else {
                    $item->{'eof'} = 1;
                }
            }
        }
    }

    #select(undef, my $wout = $win, undef, 0);
    foreach my $item (values %socket_table) {
        if ($item->{'wbuf'}) {
            send($item->filehandle, $item->{'wbuf'}, 0);
            $item->{'wbuf'} = '';
        }
    }

    $nfound = select(undef, undef, my $eout = $ein, 0);
    foreach my $item (values %socket_table) {
        #last if !$nfound;
        $item->{'eof'} = 1 if !$item->isa('server') && $item->{'tick'}+$item->{'stall'} < time;

        if ($item->{'eof'} || vec($eout, fileno($item->filehandle), 1)) {
            remove($item);
            close($item->filehandle);
            # FIXME: ungly delete in foreach
            last;
        }
    }
};

1;
