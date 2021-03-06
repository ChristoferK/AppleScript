#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: APPEND PDF LANGUAGE TO FILENAME
# nmxt: .applescript
# pDSC: Samples the text content from a few pages of a PDF file to determine the
#       most probably language and append the language code to the filename.  If
#       the filename already has the appropriate language code appended, it is
#       left unchanged.  The files get revealed in Finder.

# plst: *filepaths : An optional means to pass a list a PDF files to the run
#                    handler. From within Automator, a single directory can be
#                    passed to retrieve PDFs contained within.

# rslt: «miscmvis» : Files revealed in Finder after renaming
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2019-01-18
# asmo: 2019-01-22
# vers: 1.0
--------------------------------------------------------------------------------
use framework "Foundation"
use framework "Quartz"
use scripting additions

property this : a reference to current application

property NSArray : a reference to NSArray of this
property NSLinguisticTagger : a reference to NSLinguisticTagger of this
property NSMutableDictionary : a reference to NSMutableDictionary of this
property NSString : a reference to NSString of this
property PDFDocument : a reference to PDFDocument of this

property samples : 4 -- The (maximum) number of pages to sample for text
--------------------------------------------------------------------------------
# IMPLEMENTATION:
on run filepaths
	set [filepaths] to filepaths & {null}
	
	if class of filepaths = script or filepaths = {} then set ¬
		filepaths to [(choose file of type ["com.adobe.pdf"] ¬
		with multiple selections allowed), null]
	set [filepaths, null] to filepaths
	
	if class of filepaths ≠ list then
		set directory to POSIX file (POSIX path of filepaths) as alias
		tell application "Finder" to set filepaths to (every file ¬
			in the directory whose name extension = "PDF") ¬
			as alias list
	end if
	
	set PDFs to {}
	repeat with PDFPath in filepaths
		tell (probableLanguageForPDF at PDFPath) to if ¬
			missing value ≠ it then set end of PDFs ¬
			to (stick of me on "_" & it to PDFPath)
	end repeat
	
	tell application "Finder"
		reveal the PDFs
		activate
	end tell
end run
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:
# stick
#   Appends a suffix to the filename (without extension) of the file at the
#   specified path, without altering the file extension
to stick on suffix to fp as text
	local fp, suffix
	
	set filename to null
	
	tell (NSString's stringWithString:(fp's POSIX path)) to if ¬
		false = ((the lastPathComponent()'s ¬
		stringByDeletingPathExtension()'s hasSuffix:suffix)) ¬
		as boolean then set filename to ¬
		(((the lastPathComponent()'s ¬
			stringByDeletingPathExtension()'s ¬
			stringByAppendingString:suffix))'s ¬
			stringByAppendingPathExtension:(the ¬
				pathExtension())) as text
	
	tell application "System Events" to tell the item named fp
		if filename = null then return it as alias
		set dir to its container
		set its name to filename
		return the item named filename in dir as alias
	end tell
end stick

# probableLanguageForPDF
#   Obtain the most likely language of a PDF file based on sampling a small
#   number of its pages and returning the most commonly detected language code
on probableLanguageForPDF at PDFPath as text
	local PDFPath
	
	set PDFFileURL to POSIX file (PDFPath's POSIX path) as alias
	
	set PDF to PDFDocument's alloc()'s initWithURL:PDFFileURL
	set PDFTitle to PDF's documentAttributes()'s ¬
		objectForKey:(PDFDocumentTitleAttribute of this)
	set N to the PDF's pageCount() as integer
	
	-- Ignore first and last page unless they are the only pages
	set PDFPageNumbers to array(0, N - 1)
	set a to item 2 of (PDFPageNumbers & {0})
	set b to item -2 of ({N - 1} & PDFPageNumbers)
	if a > b then set [a, b] to [b, a]
	
	set langs to NSMutableDictionary's dictionary()
	
	-- The language of the PDF's title
	tell PDFTitle to if missing value ≠ it then tell ¬
		(NSLinguisticTagger's dominantLanguageForString:it) to if ¬
		missing value ≠ it then langs's setValue:1 forKey:it
	
	-- Select only a small sample of pages
	-- to obtain a language for each
	repeat with i from a to b by N div samples + 1
		set PDFPage to the (PDF's pageAtIndex:i)
		set PDFPageText to PDFPage's |string|()
		set PDFPageLang to (NSLinguisticTagger's ¬
			dominantLanguageForString:PDFPageText)
		tell langs to try
			set [x] to references in {valueForKey_(PDFPageLang), 0}
			setValue_forKey_((x as integer) + 1, PDFPageLang)
		end try
	end repeat
	
	-- The most common language identified (if any)
	tell langs to if {} ≠ it as record then return the last item of ¬
		keysSortedByValueUsingSelector_("compare:") as text
	
	missing value
end probableLanguageForPDF

# array()
#   Generate a list of consecutive (ascending) integers between +a and +b
on array(a as integer, b as integer)
	local a, b
	
	if a > b then set [a, b] to [b, a]
	
	script |integers|
		property list : {}
	end script
	
	repeat with i from a to b
		set the end of the list of |integers| to i
	end repeat
	
	return the list of |integers|
end array
---------------------------------------------------------------------------❮END❯