package Framework::Sourmash::Kit::Class;

use strict;
use warnings;

use Class::Inspector;
use Sub::Exporter -setup => {
    exports => [
        import => sub {
            my ($class, $name, $given) = @_;

            return sub {

                my $caller = _get_caller(@_) ;

                return if $caller eq 'main';

                $given->{do}->($caller, @_);
            };
        },
    ],
};

sub _get_caller {
    my $offset = 1;
    return
        (ref $_[1] && defined $_[1]->{into})
            ? $_[1]->{into}
            : (ref $_[1] && defined $_[1]->{into_level})
                ? caller($offset + $_[1]->{into_level})
                : caller($offset);
}

sub guess_kit_class {
    my $self = shift;
    my $class = shift;
    return join '::', do {
        my @class = split m/::/, $class;
        pop @class;
        return unless @class;
        @class;
    };
}


1;


__END__

{
    my $CALLER;

    sub import {
        $CALLER = _get_caller(@_);

        return if $CALLER eq 'main';

        shift;

        Framework::Primer::Static::Class->setup_base_class(class => $CALLER, @_);
    }

    sub _get_caller{
        my $offset = 1;
        return
            (ref $_[1] && defined $_[1]->{into})
                ? $_[1]->{into}
                : (ref $_[1] && defined $_[1]->{into_level})
                    ? caller($offset + $_[1]->{into_level})
                    : caller($offset);
    }

}

