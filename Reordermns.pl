#!/usr/bin/env perl
my $USAGE = "Usage: $0 [--inifile inifile.ini] [--section Reordermns] [--logfile logfile.log]  [--recmark lx] [--eolrep #] [--reptag __hash__] [--debug] [file.sfm]\n";
=pod
This script reorders the \\mn fields into the order they occur on the \\lx field.

The ini file should have a Reordermns section.
The recmark is optional here. It overrides the command line option.
Here is a sample:
[Reordermns]
recmark=lx
mainrefmark=mn
homographmark=hm
# parameters affecting the fuzzy search:
includehyphen=off

=cut
use 5.020;
use utf8;
use open qw/:std :utf8/;

use strict;
use warnings;
use English;
use Data::Dumper qw(Dumper);

use File::Basename;
my $scriptname = fileparse($0, qr/\.[^.]*/); # script name without the .pl
$USAGE =~ s/inifile\./$scriptname\./;
$USAGE =~ s/logfile\./$scriptname\./;

use Getopt::Long;
GetOptions (
	'inifile:s'   => \(my $inifilename = "$scriptname.ini"), # ini filename
	'section:s'   => \(my $inisection = "Reordermns"), # section of ini file to use

	'logfile:s'   => \(my $logfilename = "$scriptname.log"), # log filename
	'help'    => \my $help,

# additional options go here.
# 'sampleoption:s' => \(my $sampleoption = "optiondefault"),
	'recmark:s' => \(my $recmark = "lx"), # record marker, default lx
	'eolrep:s' => \(my $eolrep = "#"), # character used to replace EOL
	'reptag:s' => \(my $reptag = "__hash__"), # tag to use in place of the EOL replacement character
	# e.g., an alternative is --eolrep % --reptag __percent__

	# Be aware # is the bash comment character, so quote it if you want to specify it.
	#	Better yet, just don't specify it -- it's the default.
	'debug'       => \my $debug,
	) or die $USAGE;
if ($help) {
	say STDERR $USAGE;
	exit;
	}
open(my $LOGFILE, '>', $logfilename)
		or die "Could not open Log file '$logfilename' $!";

# check your options and assign their information to variables here
$recmark =~ s/[\\ ]//g; # no backslashes or spaces in record marker

use Config::Tiny;
my $config = Config::Tiny->read($inifilename, 'crlf');
die "Quitting: couldn't find the INI file $inifilename\n$USAGE\n" if !$config;

$recmark = $config->{"$inisection"}->{recmark} if $config->{"$inisection"}->{recmark};
my $mnrefmark = $config->{"$inisection"}->{mainrefmark};
my $hmmark = $config->{"$inisection"}->{homographmark};
for ($recmark, $mnrefmark, $hmmark) {
	# remove backslashes and spaces from the SFMs in the INI file
	s/\\//g;
	s/ //g;
	}
my $includehyphen = ($config->{"$inisection"}->{includehyphen} =~ /on/);
say STDERR "record marker: $recmark" if $debug;
say STDERR "mnrefmark: $mnrefmark" if $debug;
say STDERR "hmmark:$hmmark" if $debug;
say STDERR "includehyphen:$includehyphen" if $debug;

# generate array of the input file with one SFM record per line (opl)
my @opledfile_in;
my $line = ""; # accumulated SFM record
my $crlf;
while (<>) {
	$crlf = $MATCH if  s/\R//g; # chomp that doesn't care about Linux & Windows, but remembers what was chomped
	s/$eolrep/$reptag/g;
	$_ .= "$eolrep";
	if (/^\\$recmark /) {
		$line =~ s/$eolrep$/$crlf/;
		push @opledfile_in, $line;
		$line = $_;
		}
	else { $line .= $_ }
	}
push @opledfile_in, $line;
say STDERR "opledfile_in:", Dumper(@opledfile_in) if $debug;
use String::Approx qw{aindex amatch};
for my $oplline (@opledfile_in) {
	my $lx;
	my @mns; # modified \mn fields
	my @mnorgs; # unmodified \mn fields (may contain homograph/sense numbers
	my @fuzinds; # fuzzy index of location of \mn field within \lx
	say STDERR "oplline:$oplline"  if $debug;
	next if ! ($oplline =~ m/\\$recmark ([^$eolrep]+)/);
	$lx = $1;
	say STDERR "lx:$lx"  if $debug;
	$oplline =~ s/\\$mnrefmark$eolrep/\\$mnrefmark $eolrep/; # handle a bare mn marker as if it had a null field
	next if ! ($oplline =~ m/\\$mnrefmark /);
	while  ($oplline  =~ /\\$mnrefmark [^$eolrep]*$eolrep/g) {
		my $mn=$MATCH;
		push @mnorgs, $mn;
		$mn =~ s/\\$mnrefmark //;
		$mn =~ s/$eolrep//;
		$mn = lc($mn);
		$mn =~ s/ *[0-9]//g; # remove homograph and sense numbers
		$mn =~ s/\-//g unless $includehyphen;
		say $LOGFILE "Found an empty \\$mnrefmark field in record:$oplline" if length($mn) == 0;
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
		say $LOGFILE "Couldn't find (", $mns[$i], ") inside ($lx)\nIn record:$oplline" if $fuzinds[$i] < 0;
		}
	say STDERR "lx:$lx" if $debug;
	say STDERR "\\mns:" if $debug;
	foreach (@mns) {
		say STDERR $_ if $debug;
		}
	my $mnorgs_string=join q(), @mnorgs;
	say STDERR "Reordered mnorgs as string:$mnorgs_string" if $debug;
	$oplline =~ s/\\$mnrefmark [^$eolrep]*$eolrep//g; # delete the original mn fields
	$oplline =~ s/(\\$recmark [^$eolrep]+$eolrep(\\$hmmark [^$eolrep]+$eolrep)?)/$1$mnorgs_string/;
	say STDERR "final oplline:$oplline" if $debug;
	say STDERR "" if $debug;
	say STDERR "" if $debug;
	}

#output the modified file
for my $oplline (@opledfile_in) {
	for ($oplline) {
		$crlf=$MATCH if /\R/;
		s/$eolrep/$crlf/g;
		s/$reptag/$eolrep/g;
		print;
		}
	}
