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

Todo
====
* Take command arguments instead of hard-coding the requests in the script.
* Modularize?
* Add more types of formats just for fun.
