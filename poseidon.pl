#!/usr/bin/env perl

BEGIN{push(@INC, "./net")};

package main;
use strict;
use ragnarok_server;

STDOUT->autoflush(1);
STDERR->autoflush(1);

ragnarok_server::run;
