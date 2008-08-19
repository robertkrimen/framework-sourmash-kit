package Framework::Sourmash::Kit::Component;

use Moose::Role;

has kit => qw/is ro required 1 isa Framework::Sourmash::Kit::Object/;

1;
