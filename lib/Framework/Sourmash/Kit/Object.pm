package Framework::Sourmash::Kit::Object;

use warnings;
use strict;

use Moose;
use Framework::Sourmash::Kit::Carp;
use Framework::Sourmash::Kit::Types;

use Config::JFDI;
use File::Copy;
use File::Spec::Link;
use File::Find;
use Path::Class;
use MooseX::ClassAttribute();
use Class::Inspector;

has home_dir => qw/is ro coerce 1 lazy_build 1/, isa => Dir;
sub _build_home_dir {
    return Path::Class::Dir->new("./")->absolute;
}

has config_default => qw/is ro lazy_build 1/;
sub _build_config_default {
    return {};
}

has _config => qw/is ro lazy_build 1 isa Config::JFDI/;
sub _build__config {
    my $self = shift;
    return Config::JFDI->new(path => $self->home_dir."", name => $self->name);
};
sub config {
    return shift->_config->get;
}
sub cfg {
    return shift->config;
}

sub testing {
    return shift->config->{testing} ? 1 : 0;
}

has ui => qw/is ro lazy_build 1 isa Framework::Sourmash::Kit::UI::Object/;
sub _build_ui {
    my $self = shift;
    my $class = ref $self;
    my $ui_class = "${class}::UI";
    if (Class::Inspector->installed($ui_class)) {
        # TODO Load the class.. better
        eval "require $ui_class;";
        die $@ if $@;
    }
    else {
        Framework::Sourmash::Kit::UI->_setup_kit_class(create => 1, kit_class => $class, class => $ui_class, @_);
    }
    return $ui_class->new(kit => $self);
}

sub publish_dir {
    my $self = shift;
    if (1 == @_) {
        return $self->publish_dir(from_dir => shift, to_dir => $self->run_root_dir, @_);
    }
    my %given = @_;

    my $from_dir = $given{from_dir} || $given{from} or croak "Wasn't given a dir to copy from";
    my $to_dir = $given{to_dir} || $given{to} or croak "Wasn't given a dir (or path) to copy to";
    my $copy = $given{copy};
    my $skip = $given{skip} || qr/^(?:\.svn|.git|CVS|RCS|SCCS)$/;

    find { no_chdir => 1, wanted => sub {
        my $from = $_;
        if ($from =~ $skip) {
            $File::Find::prune = 1;
            return;
        }
        my $from_relative = substr $from, length $from_dir;
        my $to = "$to_dir/$from_relative";

        return if -e $to || -l $to;
        if (! -l $from && -d _) {
            dir($to)->mkpath;
        }
        else {
            if ($copy) {
                File::Copy::copy($from, $to) or warn "Couldn't copy($from, $to): $!";
            }
            else {
                my $from = File::Spec::Link->resolve($from) || $from;
                $from = file($from)->absolute;
                symlink $from, $to or warn "Couldn't symlink($from, $to): $!";
            }
        }
    } }, $from_dir;
}

sub publish {
    my $self = shift;
    if (1 == @_) {
        return $self->publish(from => shift, to => $self->run_root_dir, @_);
    }
    my %given = @_;

    my $from = $given{from} or croak "Wasn't given a path to copy from";
    my $to = $given{to} or croak "Wasn't given a path to copy to";
    my $copy = $given{copy};

    if (-f $from && -d $to) {
        croak "Given a file to copy ($from) but destination is a directory ($to)";
    }

    return $self->publish_dir(@_) unless -f $from;

    my $dir = file($to)->parent;
    $dir->mkpath unless -d $dir;

    if ($copy) {
        File::Copy::copy($from, $to) or warn "Couldn't copy($from, $to): $!";
    }
    else {
        return if -l $to;
        my $from = File::Spec::Link->resolve($from) || $from;
        $from = file($from)->absolute;
        symlink $from, $to or warn "Couldn't symlink($from, $to): $!";
    }
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

