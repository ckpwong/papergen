#!/usr/bin/env ruby

require 'prawn'

# generate dot grid in 2-up position, folding at half-height
def 2_up_dots (filename, paper_width = 612, paper_height = 792, margin = 72/4, space = 10, colour = "DDDDDD", radius = 0.75)
	half_height = paper_height / 2
	Prawn::Document.generate(filename, :page_size => [paper_width, paper_height], :margin => margin) do
		x = 0
		while x <= (paper_width - 2 * margin) do
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
end


2_up_dots "dot2.pdf"