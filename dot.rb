#!/usr/bin/env ruby

require 'prawn'

# generalized
def n_up(file_name, page_width, page_height, margin, pages, horizontal, vertical, weight, space, color, draw_func, debug = false) 
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
			for b in boxes do
				send draw_func, b, color, weight, space, debug
			end
			start_new_page unless p == pages
		end
	end
end

def draw_dots (box, color, weight, space, debug = false)
	x = box[:min_x]
	while x <= box[:max_x] do
		y = box[:min_y]
		while y <= box[:max_y] do
			fill_color color
			fill_circle [x, y], weight
			p "dot [#{x}, #{y}]" if debug
			y += space
		end
		x += space
	end
end

def draw_horizontal_rule (box, color, weight, space, debug = false)
	y = box[:min_y]
	while y <= box[:max_y] do
		stroke_color color
		stroke do
			line [box[:min_x], y], [box[:max_x], y]
			p "horizontal line: [#{box[:min_x]}, #{y}] -> [#{box[:max_x]}, #{y}]" if debug
		end
		y += space
	end
end

def n_up_horizontal_rule(file_name, horizontal = 1, vertical = 2, page_width = 612, page_height = 792, margin = 72/4, pages = 1, line_width = 0.75, space = 13.5, color = "DDDDDD", debug = false) 
	n_up file_name, page_width, page_height, margin, pages, horizontal, vertical, line_width, space, color, :draw_horizontal_rule, debug
end

def n_up_dots(file_name, horizontal = 1, vertical = 2, page_width = 612, page_height = 792, margin = 72/4, pages = 1, radius = 0.75, space = 13.5, color = "DDDDDD", debug = false) 
	n_up file_name, page_width, page_height, margin, pages, horizontal, vertical, radius, space, color, :draw_dots, debug
end

n_up_dots "2updots.pdf"
n_up_horizontal_rule "2uphlines.pdf"
n_up_dots "4updots.pdf", 2, 2
