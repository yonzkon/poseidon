package socket_raw;

use strict;
use Socket;

use constant STALL_DEFAULT => 10*60;

sub new {
    my ($class, $fh, $parent) = @_;
    my $self = {
        fh => $fh,
        eof => 0,
        tick => time,
        stall => STALL_DEFAULT,
        rbuf => '',
        wbuf => '',
        packet => undef,

        parent => $parent,
        childs => [],
    };
    #push(@$parent->{'childs'}, $self);
    bless $self, $class;
    return $self;
};

sub filehandle {
    return $_[0]->{'fh'};
}

sub eof {
    return $_[0]->{'eof'};
}

sub close {
    $_[0]->{'eof'} = 1;
}

1;
