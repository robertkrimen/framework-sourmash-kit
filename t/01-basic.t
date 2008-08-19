#!/usr/bin/perl -w

use strict;
use warnings;

use Test::Most;
plan qw/no_plan/;

ok(1);

package Xyzzy;

use Framework::Sourmash::Kit::Class import => { do => sub { return "Yoink!" } };

package Xyzzy::Alpha;

use Test::Most;

is(Xyzzy->import, "Yoink!");


package main;

1;
