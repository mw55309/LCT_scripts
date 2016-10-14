#!/usr/bin/perl

$c;

@ARGV = sort @ARGV;

foreach $f (@ARGV) {
	if ($f =~ m/.gz/) {
		open(IN, "zcat $f |");
	} else {
		open(IN, $f);
	}
	while(<IN>) {
		s/\n|\r//g;
		s/^\s+//g;
		my($gene,$count) = split(/\s+/);
		
		$c->{$gene}->{$f} = $count;
	}
	close IN;
}

print "MIR\t", join("\t", @ARGV), "\n";
foreach $mir (keys %{$c}) {
	print "$mir";
	foreach $f (@ARGV) {
		if (exists $c->{$mir}->{$f}) {
			print "\t", $c->{$mir}->{$f};
		} else {
			print "\t0", 
		}
	}
	print "\n";
}
