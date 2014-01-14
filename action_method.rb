#!/usr/bin/env ruby

require 'prawn'


# Generalized n-up.  Default is 2-up.  Specify paper size according to the way words should be printed.  Boxes are counted 
# in the following manner:
# 	1 	2 	3 	4
# 	5 	6 	7 	8
# 	9	10	11	12
# ... and so on.
def action_method(file_name, opts = {})
		o = { 
		:page_width => 792, 
		:page_height => 612, 
		:margin => 72/4, 
		:weight => 0.75, 
		:space => 13.5,
		:pages => 1, 
		:horizontal => 2,
		:vertical => 1,
		:colour => "222222",
		:action_every_n_box => 2,
		:first_action_box => 2,
		:debug => false }.merge(opts)

	boxes = calculate_boxes o[:page_width], o[:page_height], o[:margin], o[:horizontal], o[:vertical], o[:debug]
	next_action = o[:first_action_box]

	Prawn::Document.generate(file_name, :page_size => [o[:page_width], o[:page_height]], :margin => o[:margin]) do
		for p in (1 .. o[:pages]) do
			i = 0
			for b in boxes do
				i += 1
				if i == next_action then
					draw_actions_page b, o
					next_action += o[:action_every_n_box]
				else
					draw_dots b, o
				end
			end
			start_new_page unless p == o[:pages]
		end
	end
end

def calculate_boxes(page_width, page_height, margin, horizontal, vertical, debug = false)
	box_width = page_width / horizontal
	box_height = page_height / vertical
	bound_width = box_width - 2 * margin
	bound_height = box_height - 2 * margin

	boxes = Array.new

	for y in (1 .. vertical) do
		for x in (1 .. horizontal) do
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

def draw_dots (box, opts = {})
	x = box[:min_x]
	while x <= box[:max_x] do
		y = box[:min_y]
		while y <= box[:max_y] do
			fill_color opts[:colour]
			fill_circle [x, y], opts[:weight]
			p "dot [#{x}, #{y}]" if opts[:debug]
			y += opts[:space]
		end
		x += opts[:space]
	end
end

def draw_regtangle(box, opts = {} )
	o = {
		:bg_colour => "DDDDDD",
		:fg_colour => "FFFFFF",
		:title => "",
		:draw_square => false,
		:sqaure_size => 9
	}.merge(opts)

	# 1. draw regtangle
	# 2. draw square
	# 3. draw title
end

def draw_actions(box, opts = {})
	# 1. draw ref# box
	# 2. draw backburner
	# 3. draw action steps header
	# 4. space out evenly for action steps
end

def draw_action_page(box, opts = {})
	# 1. draw dot grid
	# 2. draw actions
end
