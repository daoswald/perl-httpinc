#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Data::Dumper;
use File::Spec::Functions qw(catfile);

use FindBin qw($Bin);
use lib "$Bin/../lib";

my $module_string = <<'MODULE';
package Foo::Bar;

use strict;
use warnings;

sub VERSION {return 42}

1;
MODULE


require_ok 'ModuleServer';
can_ok 'ModuleServer', qw(_find_module _read_module fetch_module);

ModuleServer->import('fetch_module');
can_ok 'main', 'fetch_module';

my $full_path = ModuleServer::_find_module('Foo/Bar.pm');
is $full_path, catfile("$Bin/../lib", 'Foo', 'Bar.pm'), '_find_module found full path.';

my $content = ModuleServer::_read_module($full_path);
is $content, $module_string, '_read_module loaded correct content.';

my $fetch_content = ModuleServer::fetch_module('Foo/Bar.pm');
is $fetch_content, $content, 'fetch_content found and fetched module Foo::Bar';

done_testing();
