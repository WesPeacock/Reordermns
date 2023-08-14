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

## Bugs and Enhancements
 - The script uses the fuzzy match String::Approx 'aindex'. It doesn't handle short words well.
 