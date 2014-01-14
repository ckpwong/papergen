#!/usr/bin/env ruby

require 'prawn'

Prawn::Document.generate("dot.pdf") do
	# Measurement unit: pt = 1/72"
	# Paper size:  US Letter by default = 612 x 792
	# Margin: 0.5" = 36 pt

	x = 0
	while x <= (612 - 72) do
		y = 0
		while y <= (792 - 72) do
			fill_color "AAAAAA"
			fill_circle [x, y], 1
		end
	end
end
