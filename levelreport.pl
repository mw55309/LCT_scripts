#!/usr/bin/perl

my %c;
my $level = shift;
my $file = shift;
open(IN, "$file");
while(<IN>) {
	
	#print;
	if (m/${level}__(\S+?)[:\t]/) {
		$c{$1}++;		
	}
}
close IN;

foreach $key (sort {$c{$b} <=> $c{$a}} keys %c) {
	print $key, "\t", $c{$key}, "\n";
}
