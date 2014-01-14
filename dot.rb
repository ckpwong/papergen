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

# generalize into n-up, defined by how is the page divided horizontally and vertically
def n_up_dots(file_name, horizontal = 1, vertical = 2, page_width = 612, page_height = 792, margin = 72/4, pages = 1, radius = 0.75, space = 13.5, color = "DDDDDD", debug = false) 
	# define boundaries for each mini-page
	box_width = page_width / horizontal
	box_height = page_height / vertical
	bound_width = box_width - 2 * margin
	bound_height = box_height - 2 * margin

	boxes = Array.new

	for x in (1 .. horizontal) do
		for y in (1 .. vertical) do
			min_x = (x - 1) * box_width
			max_x = (x - 1) * box_width + bound_width
			min_y = (y - 1) * box_height
			max_y = (y - 1) * box_height + bound_height

			p "Box: [#{min_x}, #{min_y}] -> [#{max_x}, #{max_y}]" if debug

			boxes.push ( {
				:min_x => min_x,
				:max_x => max_x,
				:min_y => min_y,
				:max_y => max_y
			} )


		end
	end

	Prawn::Document.generate(file_name, :page_size => [page_width, page_height], :margin => margin) do
		for p in (1 .. pages) do
			for box in boxes do
				x = box[:min_x]
				while x <= box[:max_x] do
					y = box[:min_y]
					while y <= box[:max_y] do
						fill_color color
						fill_circle [x, y], radius
						p "dot [#{x}, #{y}]" if debug
						y += space
					end
					x += space
				end
			end
			start_new_page unless p == pages
		end
	end
end


# dots_2_up "dot2.pdf"
n_up_dots "2updots.pdf"