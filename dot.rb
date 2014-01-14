#!/usr/bin/env ruby

require 'prawn'

# Measurement unit: pt = 1/72"
# Default paper size:  US Letter by default = 612 x 792
# Change margin to 1/4" = 18 pt

Prawn::Document.generate("dot.pdf", :margin => 18) do

	# make it 2-up: y becomes 792/2 = 396 per page
	x = 0
	while x <= (612 - 36) do
		y = 0
		z = 396
		while y <= (396 - 36) do
			fill_color "AAAAAA"
			fill_circle [x, y], 0.5
			fill_circle [x, z], 0.5
			y += 10
			z += 10
		end
		x += 10
	end
end
