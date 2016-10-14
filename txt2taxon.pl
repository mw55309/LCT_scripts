#!/usr/bin/perl

my $PATH_TO_GG_INDEX = "example/gg_13_5_taxonomy.txt.gz";

my $named_prefix = shift;

my $rid;
foreach $sam (@ARGV) {
	open(SAM, "zcat $sam |");
	while(<SAM>) {
		chomp();
		my($read,$hit) = split(/\t/, $_);
		$rid->{$read}->{$hit}++;
	}
	close SAM;
}

my %gg;
open(GG, "zcat $PATH_TO_GG_INDEX |");
while(<GG>) {
	chomp();
	s/\;\s*/:/g;
	my($id,$taxon) = split(/\s+/);
	my @taxon = split(/:/, $taxon);	
		
	my @t2;
	foreach $t (@taxon) {
		my ($one,$two) = split(/__/,$t);
		last unless ($two =~ m/\w/);
		push(@t2, $t);
	}

	my $taxon = join(":",@t2);
	$gg{$id} = $taxon;
}
close GG;

open(ALL, ">$named_prefix.taxon.all.txt");
open(LOWEST, ">$named_prefix.taxon.lowest.txt");

while(my($read,$hr) = each %{$rid}) {
	
	my @taxons;
	foreach $id (keys %{$hr}) {
		push(@taxons, $gg{$id});
		print ALL "$read\t$id\t", $gg{$id}, "\n";
	}

	if (@taxons == 1) {
		print LOWEST "$read\t$taxons[0]\tsingle\n";
	} else {
		my $lowest = &find_lowest(\@taxons);
		print LOWEST "$read\t$lowest\tlowest\n";
	}

}

close ALL;
close LOWEST;


sub find_lowest {

        my $ar = shift;
        my @all = @{$ar};

        my $main = $all[0];
        my @main = split(/:/, $main);
        @main = reverse @main;

        my $lowest = undef;

        foreach $level (@main) {
                my $count = 0;
                for($i=1;$i<@all;$i++) {
                        my $c = $all[$i];
                        my @c = split(/:/,$c);
                        @c = reverse(@c);

                        foreach $c (@c) {
				#print "Comparing $level with $c\n";
                                if ($c eq $level) {
					#print "\tAdding 1\n";
                                        $count++;
					last;
                                }
                        }
                }

                if ($count == (@all - 1)) {
                        $lowest = $level;
                        #$parent = join(":", @main);
                        #$parent =~ s/:$level.*//;
                        last;
                } else {
                        next;
                }
        }

	my $parent;
	my $i = 0;
	my @m = reverse(@main);
	while($m[$i] ne $lowest) {
		$parent .= $m[$i] . ":";
		#print "Adding $m[$i]\n";
		$i++;
	}
	
        return "$parent$lowest";
}

