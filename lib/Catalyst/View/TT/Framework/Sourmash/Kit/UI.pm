package Catalyst::View::TT::Framework::Sourmash::Kit::UI;

use strict;
use warnings;

use NEXT;
use base qw/Catalyst::View::TT/;

sub new {
    my $self = shift->NEXT::new(@_);
    return $self;
}

sub render {
    my ($self, $catalyst, $template, $context) = @_;

    $catalyst->log->debug(qq/Rendering template "$template"/) if $catalyst->debug;

    my $ui = $catalyst->model('Kit')->kit->ui;

    my %context = (
        (ref $context eq 'HASH' ? %$context : %{ $catalyst->stash() }),
        $self->template_vars($catalyst)
    );

    return $ui->process_tt(template => $template, context => \%context);
}


1;

__END__

sub process {
    my ( $self, $catalyst ) = @_;

    my $template = $c->stash->{template};

    unless (defined $template) {
        $catalyst->log->debug('No template specified for rendering') if $catalyst->debug;
        return 0;
    }

    my $output = $self->render($catalyst, $template);

    if (UNIVERSAL::isa($output, 'Template::Exception')) {
        my $error = qq/Couldn't render template "$output"/;
        $catalyst->log->error($error);
        $catalyst->error($error);
        return 0;
    }

    unless ( $catalyst->response->content_type ) {
        $catalyst->response->content_type('text/html; charset=utf-8');
    }

    $catalyst->response->body($output);

    return 1;
}

