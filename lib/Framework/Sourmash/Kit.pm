package Framework::Sourmash::Kit;

use warnings;
use strict;

=head1 NAME

Framework::Sourmash::Kit -

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Moose;
use Framework::Sourmash::Kit::Carp;
use Framework::Sourmash::Kit::Types;
use Framework::Sourmash::Kit::Class import => { do => sub {
    my $caller = shift;
    shift;
    __PACKAGE__->_setup_kit_class(class => $caller, @_);

} };

use Path::Class;
use MooseX::ClassAttribute();
use Class::Inspector;

sub _setup_kit_class {
    my $self = shift;
    my %given = @_;

    my $class = $given{class} or croak "Wasn't given a class to setup";
    my $name = $given{name} or croak "Wasn't given name for $class";

    croak "$class is not a Moose-based class" unless $class->isa(qw/Moose::Object/);

    my $superclass = __PACKAGE__ . '::Object';
    eval "require $superclass;";
    die $@ if $@;
    $class->meta->superclasses($superclass);

    $self->_setup_kit_dir($class, <<_END_);
run
run/root
run/tmp
assets
assets/root
assets/root/static
assets/root/static/css
assets/root/static/js
assets/tt
_END_

    $self->_setup_kit_dir($class, $given{dir}) if $given{dir};

    $self->_setup_config_default($class, $given{config}) if $given{config};

    MooseX::ClassAttribute::process_class_attribute($class => name => qw/is ro required 1 isa Str/, default => $name);
}

sub _setup_kit_dir {
    my $self = shift;
    my $class = shift;
    my $manifest = shift;

    for my $path (sort grep { ! /^\s*#/ } split m/\n/, $manifest) {
        my @path = split m/\//, $path;
        my $last_dir = pop @path;

        my $dir = join "_", @path, $last_dir;
        my $parent_dir = @path ? join "_", @path : qw/home/;

        my $dir_method = "${dir}_dir";
        my $parent_dir_method = "${parent_dir}_dir";
        $dir_method =~ s/\W/_/g;
        $parent_dir_method =~ s/\W/_/g;

        next if $class->can($dir_method);

        $class->meta->add_attribute($dir_method => qw/is ro required 1 coerce 1 lazy 1/, isa => Dir, default => sub {
            return shift->$parent_dir_method->subdir($last_dir);
        }, @_);
    }
}

sub _setup_kit_config_default {
    my $self = shift;
    my $class = shift;
    my $default = shift;

    my $code;
    if (ref $default eq "CODE") {
        $code = $default;
    }
    elsif (ref $default eq "HASH") {
        $code = sub { return $default };
    }
    else {
        croak "Don't understand config default $default";
    }

    $class->meta->override(_build_config_default => $code);
}

=head1 AUTHOR

Robert Krimen, C<< <rkrimen at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-framework-sourmash-kit at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Framework-Sourmash-Kit>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Framework::Sourmash::Kit


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Framework-Sourmash-Kit>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Framework-Sourmash-Kit>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Framework-Sourmash-Kit>

=item * Search CPAN

L<http://search.cpan.org/dist/Framework-Sourmash-Kit>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2008 Robert Krimen, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of Framework::Sourmash::Kit
