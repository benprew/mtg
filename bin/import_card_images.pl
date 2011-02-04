#!/usr/bin/perl

use strict;
use warnings;

my $cnt = 0;

# the process is:
# 1. Download visual spoiler, sorted by card name
# 2. dump the cards for that set to a file
# 3. Run this script with the card names as input

chdir "/home/benprew/Downloads/MB" or die $!;

while( my $line = <> ) {
	$line = lc $line;
	$line =~ s/[^a-z0-9]//g;

  my $file = "Image($cnt).jpeg";

	rename $file, "$line.jpg" or die "$file: $!";

	$cnt++;
}

