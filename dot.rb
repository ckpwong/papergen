#!/usr/bin/env ruby

require 'prawn'

Prawn::Document.generate("dot.pdf") do
	fill_color "AAAAAA"
	fill_circle [100, 100], 1
end
