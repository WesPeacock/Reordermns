#!/usr/bin/env perl
my $USAGE = "Usage: $0 [--inifile inifile.ini] [--section section] [--recmark lx] [--eolrep #] [--reptag __hash__] [--debug] [file.sfm]\n";
use String::Approx qw{aindex amatch};
use v5.20;
use utf8;
use open qw/:std :utf8/;

use strict;
use warnings;
use English;
use Data::Dumper qw(Dumper);

my $recmark= 'lx';
my $mnrefmark = "mn";
my $eolrep = "#";

my $lx;
my $debug=1;
my @opledfile_in =('\lx iyikxi-a̱kayo#\mn -ikxi#\mn a̱ka#',
'\lx atowunhɛ#\mn -hɛ#\mn wun#\mn atɔ#',
'\lx living on the wild side#\mn live#\mn side#\mn wild#');

for my $oplline (@opledfile_in) {
	my @mns; # modified \mn fields
	my @mnorgs; # unmodified \mn fields (may contain homograph/sense numbers
	my @fuzinds; # fuzzy index of location of \mn field within \lx
	say STDERR "oplline:$oplline"  if $debug;
	next if ! ($oplline =~ m/\\$recmark ([^$eolrep]+)/);
	$lx = $1;
	say STDERR "lx:$lx"  if $debug;
	next if ! ($oplline =~ m/\\$mnrefmark /);
	while  ($oplline  =~ /\\$mnrefmark [^$eolrep]*$eolrep/g) {
		my $mn=$MATCH;
		push @mnorgs, $mn;
		$mn =~ s/\\$mnrefmark //;
		$mn =~ s/$eolrep//;
		$mn = lc($mn);
		$mn =~ s/ *[0-9]//g; # remove homograph and sense numbers
		push @mns, $mn;
		}
	foreach (@mns) {
		push @fuzinds, aindex ($_, $lx);
		}
	# H/T https://stackoverflow.com/a/16397775/1170224
	my @order = sort { $fuzinds[$a] <=> $fuzinds [$b] } 0 .. $#fuzinds;
	print STDERR "mnorgs:", Dumper @mnorgs  if $debug;
	print STDERR "mns:", Dumper @mns  if $debug;
	print STDERR "fuzinds:", Dumper @fuzinds  if $debug;
	print STDERR "order:", Dumper @order  if $debug;
	@mnorgs = @mnorgs[@order];
	@mns = @mns[@order];
	@fuzinds = @fuzinds[@order];
	for ( my $i = 0; $i < @fuzinds; $i++ ) {
		say STDERR "Couldn't find (", $mns[$i], ") inside ($lx)\nIn line:$oplline" if $fuzinds[$i] < 0;
		}
	say STDERR "lx:$lx" if $debug;
	say STDERR "\\mns:" if $debug;
	foreach (@mns) {
		say STDERR $_ if $debug;
		}
	say STDERR join q(), @mnorgs if $debug;
	}
