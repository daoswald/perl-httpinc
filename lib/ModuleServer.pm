package ModuleServer;

use strict;
use warnings;
use Fcntl qw(:flock);
use File::Spec::Functions qw(catfile);
use parent 'Exporter';
our @EXPORT_OK = qw(fetch_module);


sub fetch_module {
    my $file = shift;
    my $to_load = eval {_find_module($file)};
    die "Unable to load $file:$@\n" if $@ || !$to_load;
    my $content = eval {_read_module($to_load)};
    die "Unable to load $to_load: $@" if $@ || !$content;
    return $content;
}

sub _find_module {
    my $file = shift;
    my $wanted;
    for my $path (@INC) {
        next if ref($path) && $path == \&load; # Skip self, which is probably the last element in @INC.
        my $full_path = catfile($path, $file);
        if (-e $full_path) {
            $wanted = $full_path;
            last;
        }
    }
    die "Unable to find module" unless $wanted;
    return $wanted;
}

sub _read_module {
    my $target = shift;
    open my $fh, '<', $target or die $!;
    flock $fh, LOCK_SH || die $!;
    local $/ = "\n__END__";
    chomp(my $content = <$fh>);
    return $content . "\n";
}

1;

