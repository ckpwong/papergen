#!/usr/bin/env ruby

require 'prawn'

# generate dot grid in 2-up position, folding at half-height
def dots_2_up (filename, paper_width = 612, paper_height = 792, margin = 72/4, space = 10, colour = "DDDDDD", radius = 0.75)
	half_height = paper_height / 2
	Prawn::Document.generate(filename, :page_size => [paper_width, paper_height], :margin => margin) do
		x = 0
		while x <= (paper_width - 2 * margin) do
			y = 0
			z = half_height
			while y <= (half_height / 2 - 2 * margin) do
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


dots_2_up "dot2.pdf"