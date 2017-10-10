#!/usr/bin/env perl

BEGIN{push(@INC, "./net")};

package main;
use strict;
use ragnarok_server;
use query_server;

STDOUT->autoflush(1);
STDERR->autoflush(1);

ragnarok_server::init;
query_server::init;

while (1) {
	ragnarok_server::loop(0);
	query_server::loop(0.1);
}
