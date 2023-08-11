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
=pod
my $lx= $1 if /\\lx ([^#]*)/;
if (/(\\mn[^#]*#)+/) {
	say "lx:$lx";
	my $mns=$MATCH;
	$mns =~ s/\\mn //g;
	my @a = split (/#/, $mns);
	foreach ( @a) {
		say ">$_<";
		}
	}
=cut
my $lx; my @mns; my @fuzinds; my $debug=1;
$lx = 'living on the wild side';
@mns = split /#/, 'live#side#wild';
$lx = 'iyikxi-a̱kayo';
@mns = split /#/, '-ikxi#a̱ka';
$lx = 'now was the time for all good men too come too the aid ofg the party';
@mns = qw /now was the time for all good men too come too the aid off the party/;
$lx = 'atowunhɛ';
@mns = split /#/, '-hɛ#wun#atɔ';
say "@mns";
say "=====";
foreach (@mns) {
	push @fuzinds, aindex ($_, $lx);
	}
say STDERR "@fuzinds" if $debug;
# H/T https://stackoverflow.com/a/16397775/1170224
#my @idx = sort { $fuzinds[$a] <=> $fuzinds [$b] } 0 .. $#fuzinds;
my @idx = sort {  aindex ($mns[$a], $lx) <=> aindex ($mns[$b], $lx) } 0 .. $#mns;
@mns = @mns[@idx];
say $lx;
foreach (@mns) {
	say $_;
	}