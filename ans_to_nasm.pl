#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;

open my $fh, "<", $ARGV[0];

my $d = join("", <$fh>);
$d =~ s/\R\z//g;
my @cs = map { ord } split("", $d);

#shift(@cs);
#shift(@cs);
#shift(@cs);

for(my $y = 0; $y < 16; $y++){
    print "db ".join(",", map {sprintf("%03d", $_)} @cs[($y * 77)...($y * 77) + 77])."\n";
}

print "db 0\n"