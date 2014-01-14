#!/usr/bin/env ruby

require 'prawn'


# generalized n-up
def n_up(file_name, page_width, page_height, margin, pages, horizontal, vertical, weight, space, color, draw_func, debug = false) 
	boxes = calculate_boxes page_width, page_height, margin, horizontal, vertical, debug

	Prawn::Document.generate(file_name, :page_size => [page_width, page_height], :margin => margin) do
		for p in (1 .. pages) do
			for b in boxes do
				send draw_func, b, color, weight, space, debug
			end
			start_new_page unless p == pages
		end
	end
end

def calculate_boxes(page_width, page_height, margin, horizontal, vertical, debug = false)
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

	return boxes
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

def draw_vertical_rule (box, color, weight, space, debug = false)
	x = box[:min_x]
	while x <= box[:max_x] do
		stroke_color color
		stroke do
			line [x, box[:min_y]], [x, box[:max_y]]
			p "vertical line: [#{x}, #{box[:min_y]}] -> [#{x}, #{box[:max_y]}]" if debug
		end
		x += space
	end
end

def draw_grid (box, color, weight, space, debug = false)
	# redefining box size to make sure all sides are closed, and use horizontal_rule and vertical_rule to actually draw the lines
	b = Hash.new
	b[:min_x] = box[:min_x]
	b[:min_y] = box[:min_y]
	b[:max_x] = ((box[:max_x] - box[:min_x]) / space).floor * space + box[:min_x]
	b[:max_y] = ((box[:max_y] - box[:min_y]) / space).floor * space + box[:min_y]
	draw_horizontal_rule b, color, weight, space, debug
	draw_vertical_rule b, color, weight, space, debug
end

# generate dots in equilateral triangle with height = space
def draw_vertical_tri_dots (box, color, weight, space, debug = false)
    v_space = space / Math.tan(Math::PI/3) * 2
    odd = true
	x = box[:min_x]
	while x <= box[:max_x] do
		y = odd ? box[:min_y] : box[:min_y] + v_space / 2
		odd = !odd
		while y <= box[:max_y] do
			fill_color color
			fill_circle [x, y], weight
			p "dot [#{x}, #{y}]" if debug
			y += space
		end
		x += v_space
	end
end

def draw_horizontal_tri_dots (box, color, weight, space, debug = false)
    h_space = space / Math.tan(Math::PI/3) * 2
    odd = true
	y = box[:min_y]
	while y <= box[:max_y] do
		x = odd ? box[:min_x] : box[:min_x] + h_space / 2
		odd = !odd
		while x <= box[:max_x] do
			fill_color color
			fill_circle [x, y], weight
			p "dot [#{x}, #{y}]" if debug
			x += space
		end
		y += h_space
	end
end

# generate dots in periods
def draw_horizontal_fib_dots (box, color, weight, space, debug = false)
	n1 = 1
	n2 = 2
	bound_width = box[:max_x] - box[:min_x]
	grow = true
	y = box[:min_y]

	# grow the sequence to a reasonable size for asethetics
	while bound_width * 1.0 / (n2 - 1) > 6 * space
		t = n1
		n1 = n2
		n2 = n1 + t
	end

	min_n1 = n1

	while y <= box[:max_y] do
		x = box[:min_x]

		line_space = bound_width * 1.0 / (n2 - 1)

		while x < box[:max_x] do
			fill_color color
			fill_circle [x, y], weight
			p "dot [#{x}, #{y}]" if debug
			x += line_space
		end

		fill_color color
		fill_circle [box[:max_x], y], weight
		p "dot [#{box[:max_x]}, #{y}]" if debug

		if grow and bound_width * 1.0 / (n1 + n2 - 1) < space then
			grow = false
		elsif !grow and n1 == min_n1 then
			grow = true
		end

		if grow then
			t = n1
			n1 = n2
			n2 = n1 + t
		else
			t = n2
			n2 = n1
			n1 = t - n2
		end
		y += space
	end
end

def draw_vertical_fib_dots (box, color, weight, space, debug = false)
	n1 = 1
	n2 = 2
	bound_height = box[:max_y] - box[:min_y]
	grow = true
	x = box[:min_x]

	# grow the sequence to a reasonable size for asethetics
	while bound_height * 1.0 / (n2 - 1) > 6 * space
		t = n1
		n1 = n2
		n2 = n1 + t
	end

	min_n1 = n1
	while x <= box[:max_x] do
		y = box[:min_y]

		line_space = bound_height * 1.0 / (n2 - 1)

		while y < box[:max_y] do
			fill_color color
			fill_circle [x, y], weight
			p "dot [#{x}, #{y}]" if debug
			y += line_space
		end

		fill_color color
		fill_circle [x, box[:max_y]], weight
		p "dot [#{x}, #{box[:max_y]}]" if debug

		if grow and bound_height * 1.0 / (n1 + n2 - 1) < space then
			grow = false
		elsif !grow and n1 == min_n1 then
			grow = true
		end

		if grow then
			t = n1
			n1 = n2
			n2 = n1 + t
		else
			t = n2
			n2 = n1
			n1 = t - n2
		end
		x += space
	end
end
def n_up_horizontal_rule(file_name, horizontal = 1, vertical = 2, page_width = 612, page_height = 792, margin = 72/4, pages = 1, line_width = 0.75, space = 13.5, color = "DDDDDD", debug = false) 
	n_up file_name, page_width, page_height, margin, pages, horizontal, vertical, line_width, space, color, :draw_horizontal_rule, debug
end

def n_up_vertical_rule(file_name, horizontal = 1, vertical = 2, page_width = 612, page_height = 792, margin = 72/4, pages = 1, line_width = 0.75, space = 13.5, color = "DDDDDD", debug = false) 
	n_up file_name, page_width, page_height, margin, pages, horizontal, vertical, line_width, space, color, :draw_vertical_rule, debug
end

def n_up_grid(file_name, horizontal = 1, vertical = 2, page_width = 612, page_height = 792, margin = 72/4, pages = 1, radius = 0.75, space = 13.5, color = "DDDDDD", debug = false) 
	n_up file_name, page_width, page_height, margin, pages, horizontal, vertical, radius, space, color, :draw_grid, debug
end

def n_up_dots(file_name, horizontal = 1, vertical = 2, page_width = 612, page_height = 792, margin = 72/4, pages = 1, radius = 0.75, space = 13.5, color = "DDDDDD", debug = false) 
	n_up file_name, page_width, page_height, margin, pages, horizontal, vertical, radius, space, color, :draw_dots, debug
end

def n_up_vertical_tri_dots(file_name, horizontal = 1, vertical = 2, page_width = 612, page_height = 792, margin = 72/4, pages = 1, radius = 0.75, space = 13.5, color = "DDDDDD", debug = false) 
	n_up file_name, page_width, page_height, margin, pages, horizontal, vertical, radius, space, color, :draw_vertical_tri_dots, debug
end

def n_up_horizontal_tri_dots(file_name, horizontal = 1, vertical = 2, page_width = 612, page_height = 792, margin = 72/4, pages = 1, radius = 0.75, space = 13.5, color = "DDDDDD", debug = false) 
	n_up file_name, page_width, page_height, margin, pages, horizontal, vertical, radius, space, color, :draw_horizontal_tri_dots, debug
end

def n_up_horizontal_fib_dots(file_name, horizontal = 1, vertical = 2, page_width = 612, page_height = 792, margin = 72/4, pages = 1, radius = 0.75, space = 13.5, color = "222222", debug = false) 
	n_up file_name, page_width, page_height, margin, pages, horizontal, vertical, radius, space, color, :draw_horizontal_fib_dots, debug
end

def n_up_vertical_fib_dots(file_name, horizontal = 1, vertical = 2, page_width = 612, page_height = 792, margin = 72/4, pages = 1, radius = 0.75, space = 13.5, color = "222222", debug = false) 
	n_up file_name, page_width, page_height, margin, pages, horizontal, vertical, radius, space, color, :draw_vertical_fib_dots, debug
end

n_up_dots "2updots.pdf"
n_up_horizontal_rule "2uphlines.pdf"
n_up_dots "4updots.pdf", 2, 2
n_up_vertical_rule "2upvlines.pdf"
n_up_grid "2upgrid.pdf"
n_up_horizontal_tri_dots "2uphtridots.pdf"
n_up_vertical_tri_dots "2upvtridots.pdf"
n_up_horizontal_fib_dots "2uphfibdots.pdf"
n_up_vertical_fib_dots "2upvfibdots.pdf"