#!/usr/bin/perl

use strict;
use warnings;

my $cnt = 0;
my @cards;

# the process is:
# 1. Download visual spoiler, sorted by card name
# 2. dump the cards for that set to a file
# 3. Run this script with the card names as input
# 4. Copy the directory (ex. newphyrexia) to public/sets

# For some reason, Gatherer sorts cards as if the ' wasn't there, ex:
# Phyrexian Oaf
# Phyrexia's Life

while ( my $line = <> ) {
    $line = lc $line;
    $line =~ s/[^a-z0-9 ]//g;
    push @cards, $line;
}

@cards = sort { $a cmp $b } @cards;

for my $card (@cards)
{
    $card =~ s/\s+//g;

    my $file = $cnt == 0 ? "Image.ashx" : "Image($cnt).ashx";

    rename $file, "$card.jpg" or die "$file: $!";

    $cnt++;
}

