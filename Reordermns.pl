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
say STDERR "record marker: $recmark" if $debug;
say STDERR "mnrefmark: $mnrefmark" if $debug;
say STDERR "hmmark:$hmmark" if $debug;

# generate array of the input file with one SFM record per line (opl)
my @opledfile_in;
my $line = ""; # accumulated SFM record
while (<>) {
	s/\R//g; # chomp that doesn't care about Linux & Windows
	s/$eolrep/$reptag/g;
	$_ .= "$eolrep";
	if (/^\\$recmark /) {
		$line =~ s/$eolrep$/\n/;
		push @opledfile_in, $line;
		$line = $_;
		}
	else { $line .= $_ }
	}
push @opledfile_in, $line;
die;
for my $oplline (@opledfile_in) {
# Insert code here to perform on each opl'ed line.
# Note that a next command will prevent the line from printing

say STDERR "oplline:", Dumper($oplline) if $debug;
#de_opl this line
	for ($oplline) {
		s/$eolrep/\n/g;
		s/$reptag/$eolrep/g;
		print;
		}
	}
