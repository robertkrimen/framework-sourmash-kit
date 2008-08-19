#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Framework::Sourmash::Kit' );
}

diag( "Testing Framework::Sourmash::Kit $Framework::Sourmash::Kit::VERSION, Perl $], $^X" );
