#!/usr/bin/env perl
use Mojolicious::Lite;
use FindBin qw($Bin);

use lib "$Bin/../lib";
use ModuleServer qw(fetch_module);

plugin 'Subprocess';

get '/*modpath' => sub {
    my $c = shift;
    my $path = $c->param('modpath');
    $c->render_later;
    $c->subprocess(
        sub {
            return fetch_module($path);
        },
        sub {
            my ($c, $code) = @_;
            $c->render(data => $code);
        },
    );
};

app->start;
