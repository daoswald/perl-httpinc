#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Data::Dumper;
use JSON qw(decode_json);

use FindBin qw($Bin);
use lib "$Bin/../lib";

use_ok 'NetLoader';

my @subs = qw(load _ua _get);
can_ok 'NetLoader', $_ for @subs;

ok scalar(grep {$_ eq \&NetLoader::load} @INC), 'NetLoader::load was pushed onto @INC';

my $ua = NetLoader::_ua();

is ref($ua), 'HTTP::Tiny', 'NetLoader::_ua returns a user agent.';
is $NetLoader::UA, NetLoader::_ua(), 'User agent is cached in package global.';

my $resp = NetLoader::_get('Foo/Bar.pm');
like $resp, qr/^package Foo::Bar;/, '_get returned actual module as content.';

my @resp = NetLoader::load(\&NetLoader::load, 'Foo/Bar.pm');
#is $resp[0], undef, 'load returned undef as first element.';
#is ref($resp[1]), 'GLOB', 'load returned a filehandle as second element.';
is ref($resp[0]), 'GLOB', 'load returned a filehandle as first element (violates require docs, but works.)';

{
    local(@INC) = (\&NetLoader::load);
    require_ok 'Foo::Bar';
    can_ok 'Foo::Bar', 'VERSION';
    my $v = Foo::Bar::VERSION();
    is $v, 42, 'Successfully ran Foo::Bar::VERSION().';
}

done_testing();
