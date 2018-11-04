-- Converts Latin text with only U/u to correct forms with V
set specials to {"cvi", "dvo", "llu"}
set repl to {"cui", "duo", "llu"}
set i to the number of items of specials

set snippet to the clipboard
set snippet to my replace(snippet, quote, "qqqqq")

display dialog snippet
-- First make all u into v
set snippet to do shell script "echo " & snippet & " | perl -pe 's/u/v/g'"
-- Word-final v -> u
set snippet to do shell script "echo " & snippet & " | perl -pe 's/v\\b/u/g'"
-- q followed by u
set snippet to do shell script "echo " & snippet & " | perl -pe 's/([Qq])v/\\1u/g'"
-- between two consonants -> u
set snippet to do shell script "echo " & snippet & " | perl -pe 's/(?=[b-df-hj-np-tv-zB-DF-HJ-NP-TV-Z])v(?=[b-df-hj-np-tv-zB-DF-HJ-NP-TV-Z])/\\1u\\2/g'"
-- after vowel & before consonant -> u
set snippet to do shell script "echo " & snippet & " | perl -pe 's/([aeiouAEIOU])v([b-df-hj-np-tv-z])/\\1u\\2/g'"
-- after certain consonants & before vowel -> u
set snippet to do shell script "echo " & snippet & " | perl -pe 's/([bcfghjkmnp-tvxzBCFGHJKMNP-TXZ])v([aeiou])/\\1u\\2/g'"
-- word-initial followed by consonant -> u
set snippet to do shell script "echo " & snippet & " | perl -pe 's/\\bv([b-df-hj-np-tv-z])/u\\1/g'"
-- Caps too
set snippet to do shell script "echo " & snippet & " | sed 's/U/V/g'"
set snippet to do shell script "echo " & snippet & " | perl -pe 's/V\\b/U/g'"
set snippet to do shell script "echo " & snippet & " | perl -pe 's/([Qq])V/\\1U/g'"
set snippet to do shell script "echo " & snippet & " | perl -pe 's/(?=[B-DF-HJ-NP-TV-Z])V(?=[B-DF-HJ-NP-TV-Z])/\\1U\\2/g'"
set snippet to do shell script "echo " & snippet & " | perl -pe 's/(?=[AEIOU])V(?=[B-DF-HJ-NP-TV-Z])/\\1U\\2/g'"
set snippet to do shell script "echo " & snippet & " | perl -pe 's/([BCFGHJKMNP-TXZ])V([AEIOU])/\\1U\\2/g'"
set snippet to do shell script "echo " & snippet & " | perl -pe 's/\\bV([B-DF-HJ-NP-TV-Z])/U\\1/g'"

-- Fix special words
repeat with j from 1 to i
	set snippet to do shell script "echo " & snippet & " | perl -pe 's/" & item j of specials & "/" & item j of repl & "/g'"
end repeat

set snippet to my replace(snippet, "qqqqq", quote)

-- Quick search and replace with TID
on replace(origtext, ftext, rtext)
	set tid to AppleScript's text item delimiters
	set newtext to origtext
	set AppleScript's text item delimiters to ftext
	set newtext to the text items of newtext
	set AppleScript's text item delimiters to rtext
	set newtext to the text items of newtext as string
	set AppleScript's text item delimiters to tid
	return newtext
end replace
