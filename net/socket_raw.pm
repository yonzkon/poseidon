package socket_raw;

use strict;
use Socket;

sub new {
    my ($class, $fh, $parent) = @_;
    my $self = {
        fh => $fh,
        eof => 0,
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

sub close {
    $_[0]->{'eof'} = 1;
}

1;
