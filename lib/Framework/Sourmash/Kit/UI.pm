package Framework::Sourmash::Kit::UI;

use Moose;
use Framework::Sourmash::Kit::Carp;
use Framework::Sourmash::Kit::Types;
use Framework::Sourmash::Kit::Class import => { do => sub {
    my $caller = shift;
    shift;
    __PACKAGE__->_setup_kit_class(class => $caller, @_);

} };

sub _setup_kit_class {
    my $self = shift;
    my %given = @_;

    my $class = $given{class} or croak "Wasn't given a class to setup";
    my $kit_class = $given{kit_class} || Framework::Sourmash::Kit::Class->guess_kit_class($class) or 
        croak "Wasn't given a kit class and couldn't guess one from $class"; 

    my $meta;
    if ($given{create}) {
        $meta = Moose::Meta::Class->create($class);
        $meta->superclasses(qw/Moose::Object/);
    }
    else {
        croak "$class is not a Moose-based class" unless $class->isa(qw/Moose::Object/);
        $meta = $class->meta;
    }

    my $superclass = __PACKAGE__ . '::Object';
    eval "require $superclass;";
    die $@ if $@;
    $class->meta->superclasses($superclass);

    $meta->add_method($kit_class->name => sub {
        return $_[0]->kit;
    });
}

1;
