package socket_raw;

use strict;
use Socket;

sub new {
    my $class = shift;
    my $self = {
        fh => shift,
        eof => 0,
        rbuf => '',
        wbuf => '',
        packet => undef,
    };
    bless $self, $class;
    return $self;
};

sub filehandle {
    return $_[0]->{'fh'};
}

sub close {
    $_[0]->{'eof'} = 1;
}

1;
