# Re-Order Main References
This repo has an opl/de_opl script to reorder the *\\mn* fields in a complex form in the order they occur in the *\\lx* field.
## Why run this script
When the *addmainrefs.pl* script is run it adds the *\\mn* fields in reverse alphabetic order. A better default order is by the order they occur in the headword. This script puts them in that order.

## An Example
Here is an example, "turn over a new leaf" from a [Pig Latin](https://en.wikipedia.org/wiki/Pig_Latin) database. For the sake of brevity, entries for *"leaf2"*, *"new"* and *"turn over"* are not included. They would each have an idiom subentry field *"\\sei urntay overway away ewnay eaflay"*:

````SFM
\lx urntay overway away ewnay eaflay
\mn eaflay2
\mn ewnay
\mn urntay overway
\ps v
\gl turn over a new leaf
````
This script will reorder the *\\mn* fields into the order they occur on the *\\lx* field like this:

````SFM
\lx urntay overway away ewnay eaflay
\mn urntay overway
\mn ewnay
\mn eaflay2
\ps v
\gl turn over a new leaf
````
*"leaf2"* is marked as homograph *2* because it is "leaf of a book". Presumably, "leaf of a tree" would be homograph *1*.

## INI file
The script reads an initialization file that affects how it runs. It allows you to change some of the SFM markers the default behaviour is in parentheses:
- record marker (*\\lx*)
- main reference (*\\mn*)
- homograph marker (*\\hm*)

It allows you to specify whether to include a hyphen in the search (*no)).
You can also change how much difference the fuzzy search will allow in a match (*35%* - about one character in three) See https://metacpan.org/pod/String::Approx#MODIFIERS for how that works.

## Log file
The script writes errors it finds to the log file.
It flags records with empty *\\mn* fields and those where it couldn't find the *\\mn* field in the record.
By default the log file has the same name as the script and is left in the current directory.

## Bugs and Enhancements
 - The script uses the fuzzy match String::Approx 'aindex'. It doesn't handle short words well.
 - The script could handle prefixes, suffixes, infixes and circumfixes as special cases. It currently either ignores them or includes them.
 