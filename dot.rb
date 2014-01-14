#!/usr/bin/env ruby

require 'prawn'

# Measurement unit: pt = 1/72"
# Default paper size:  US Letter by default = 612 x 792
# Change margin to 1/4" = 18 pt

page_width = 612
page_height = 792
margin = 72/4
space = 10
colour = "AAAAAA"

Prawn::Document.generate("dot.pdf", :margin => 18) do

	# make it 2-up: y becomes 792/2 = 396 per page
	x = 0
	while x <= (page_width - 2 * margin)
		y = 0
		z = page_height / 2
		while y <= (page_height / 2 - 2 * margin) do
			fill_color colour
			fill_circle [x, y], 0.5
			fill_circle [x, z], 0.5
			y += space
			z += space
		end
		x += space
	end
end
