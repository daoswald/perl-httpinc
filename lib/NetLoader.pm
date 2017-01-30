package NetLoader;

use strict;
use warnings;
use HTTP::Tiny;
use File::Spec::Functions qw(splitdir splitpath);
use Data::Dumper;

push @INC, \&load;
our $UA;

sub load {
    my ($self_code, $file) = @_;
    my $content = _get($file);
    open my $fh, '<', \$content or die $!;
# return (undef, $fh); # According to perldoc -f require, this should work.
    return ($fh); # But instead, this works.
}

sub _ua {return $UA //= HTTP::Tiny->new}

sub _get {
    my $query = shift;
    my $resp = _ua()->get("http://localhost:3000/$query");
    if ($resp->{'status'} ne '200') {
        die "HTTP Get failure.\n", Dumper($resp);
    }
    return $resp->{'content'};
}

1;

__END__


