package Catalyst::Model::Framework::Sourmash::Kit;

use strict;
use warnings;

use NEXT;
use base qw/Catalyst::Model/;

sub new {
    my $self = shift->NEXT::new(@_);
    return $self;
}

sub kit {
    die "Nothing to do";
}

1;
