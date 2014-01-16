papergen -- N-up grid/ruled/dot paper generator
=====

I wanted dot grid paper in Half-Letter size.  I want the grid size to be precise, not printing a full Letter size page in 2-up mode.

So I wrote my own script using Ruby and the Prawn gem.

The script currently supports the following format:

* square dot grid
* horizontally ruled
* vertically ruled
* square grid
* horizontally-aligned equilateral triangle dot grid
* vertically-aligned equilateral triangle dot grid
* horizontally-aligned oscilliating Fibonacci sequence-based dot grid (EXPERIMENTAL)
* vertically-aligned oscilliating Fibonacci sequence-based dot grid (EXPERIMENTAL)

The n-up is specified by the number of rows and columns to partition the page into.  Default is 2-up.

Paper size is US Letter by default.

Usage
-----
From the command line help:

  -h, --help:
		Show help.

	-r, --rows:
		Number of rows to split the page into.  Default is 1.

	-l, --columns:
		Number of columns to split the page into.  Default is 2.

	-n, --numpages:
		Number of pages to create.  Default is 1.

	-w, --weight:
		The size, in pt (1/72"), should each dot/line be drawn.  Default is 0.5.

	-s, --spacing:
		How far apart, in pt (1/72"), should the dots/lines be apart.  Default is 13.5.

	-c, --colour:
		The colour, in hex RGB value, of the dots/lines to be drawn.  Default is "DDDDDD".

	-t, --type:
		The type of paper to be drawn.  Here are the supported types:

			dots 		Dots in a square grid pattern
			hrule 		Horizontally ruled
			vrule 		Vertically ruled
			grid 		Square grid
			htridots 	Dots in a horizontally-aligned triangle grid pattern 
			vtridots 	Dots in a vertically-aligned triangle grid pattern 
			hfibdots 	Horizontally-aligned dots in Fibonacci sequence (EXPERMENTAL)
			vfibdots 	Vertically-aligned dots in Fibonacci sequence (EXPERMENTAL)

		Default is "dots"

	--pagewidth:
		The page width in pt (1/72").

	--pageheight:
		The page height in pt (1/72").

	-v, --verbose:
		Turn on debug messages.

Todo
----
* Modularize?
* Add more types of formats just for fun.
