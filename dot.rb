#!/usr/bin/env ruby

require 'prawn'
require 'getoptlong'


# generalized n-up
def n_up(file_name, opts = {})
		o = { 
		:horizontal => 1, 
		:vertical => 2, 
		:page_width => 612, 
		:page_height => 792, 
		:margin => 72/4, 
		:pages => 1, 
		:weight => 0.5, 
		:space => 13.5, 
		:colour => "222222", 
		:debug => false }.merge(opts)

	boxes = calculate_boxes o[:page_width], o[:page_height], o[:margin], o[:horizontal], o[:vertical], o[:debug]

	Prawn::Document.generate(file_name, :page_size => [o[:page_width], o[:page_height]], :margin => o[:margin]) do
		for p in (1 .. o[:pages]) do

			for b in boxes do
				send o[:draw_method], b, o
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

def draw_horizontal_rule (box, opts = {})
	y = box[:min_y]
	while y <= box[:max_y] do
		stroke_color opts[:colour]
		stroke do
			line [box[:min_x], y], [box[:max_x], y]
			p "horizontal line: [#{box[:min_x]}, #{y}] -> [#{box[:max_x]}, #{y}]" if opts[:debug]
		end
		y += opts[:space]
	end
end

def draw_vertical_rule (box, opts = {})
	x = box[:min_x]
	while x <= box[:max_x] do
		stroke_color opts[:colour]
		stroke do
			line [x, box[:min_y]], [x, box[:max_y]]
			p "vertical line: [#{x}, #{box[:min_y]}] -> [#{x}, #{box[:max_y]}]" if opts[:debug]
		end
		x += opts[:space]
	end
end

def draw_grid (box, opts = {})
	# redefining box size to make sure all sides are closed, and use horizontal_rule and vertical_rule to actually draw the lines
	b = Hash.new
	b[:min_x] = box[:min_x]
	b[:min_y] = box[:min_y]
	b[:max_x] = ((box[:max_x] - box[:min_x]) / opts[:space]).floor * opts[:space] + box[:min_x]
	b[:max_y] = ((box[:max_y] - box[:min_y]) / opts[:space]).floor * opts[:space] + box[:min_y]
	draw_horizontal_rule b, opts
	draw_vertical_rule b, opts
end

# generate dots in equilateral triangle with height = space
def draw_vertical_tri_dots (box, opts = {})
    v_space = opts[:space] / Math.tan(Math::PI/3) * 2
    odd = true
	x = box[:min_x]
	while x <= box[:max_x] do
		y = odd ? box[:min_y] : box[:min_y] + v_space / 2
		odd = !odd
		while y <= box[:max_y] do
			fill_color opts[:colour]
			fill_circle [x, y], opts[:weight]
			p "dot [#{x}, #{y}]" if opts[:debug]
			y += opts[:space]
		end
		x += v_space
	end
end

def draw_horizontal_tri_dots (box, opts = {})
    h_space = opts[:space] / Math.tan(Math::PI/3) * 2
    odd = true
	y = box[:min_y]
	while y <= box[:max_y] do
		x = odd ? box[:min_x] : box[:min_x] + h_space / 2
		odd = !odd
		while x <= box[:max_x] do
			fill_color opts[:colour]
			fill_circle [x, y], opts[:weight]
			p "dot [#{x}, #{y}]" if opts[:debug]
			x += opts[:space]
		end
		y += h_space
	end
end

# generate dots in periods
def draw_horizontal_fib_dots (box, opts = {})
	n1 = 1
	n2 = 2
	bound_width = box[:max_x] - box[:min_x]
	grow = true
	y = box[:min_y]

	# grow the sequence to a reasonable size for asethetics
	while bound_width * 1.0 / (n2 - 1) > 6 * opts[:space]
		t = n1
		n1 = n2
		n2 = n1 + t
	end

	min_n1 = n1

	while y <= box[:max_y] do
		x = box[:min_x]

		line_space = bound_width * 1.0 / (n2 - 1)

		while x < box[:max_x] do
			fill_color opts[:colour]
			fill_circle [x, y], opts[:weight]
			p "dot [#{x}, #{y}]" if opts[:debug]
			x += line_space
		end

		fill_color opts[:colour]
		fill_circle [box[:max_x], y], opts[:weight]
		p "dot [#{box[:max_x]}, #{y}]" if opts[:debug]

		if grow and bound_width * 1.0 / (n1 + n2 - 1) < opts[:space] then
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
		y += opts[:space]
	end
end

def draw_vertical_fib_dots (box, opts = {})
	n1 = 1
	n2 = 2
	bound_height = box[:max_y] - box[:min_y]
	grow = true
	x = box[:min_x]

	# grow the sequence to a reasonable size for asethetics
	while bound_height * 1.0 / (n2 - 1) > 6 * opts[:space]
		t = n1
		n1 = n2
		n2 = n1 + t
	end

	min_n1 = n1
	while x <= box[:max_x] do
		y = box[:min_y]

		line_space = bound_height * 1.0 / (n2 - 1)

		while y < box[:max_y] do
			fill_color opts[:colour]
			fill_circle [x, y], opts[:weight]
			p "dot [#{x}, #{y}]" if opts[:debug]
			y += line_space
		end

		fill_color opts[:colour]
		fill_circle [x, box[:max_y]], opts[:weight]
		p "dot [#{x}, #{box[:max_y]}]" if opts[:debug]

		if grow and bound_height * 1.0 / (n1 + n2 - 1) < opts[:space] then
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
		x += opts[:space]
	end
end
# def n_up_horizontal_rule(file_name, opts = {})
# 	opts[:draw_method] = :draw_horizontal_rule
# 	opts[:weight] = opts[:line_width] if opts.has_key? :line_width
# 	n_up file_name, opts
# end

# def n_up_vertical_rule(file_name, opts = {})
# 	opts[:draw_method] = :draw_vertical_rule
# 	opts[:weight] = opts[:line_width] if opts.has_key? :line_width
# 	n_up file_name, opts
# end

# def n_up_grid(file_name, opts = {})
# 	opts[:draw_method] = :draw_grid
# 	opts[:weight] = opts[:line_width] if opts.has_key? :line_width
# 	n_up file_name, opts
# end

# def n_up_dots(file_name, opts = {})
# 	opts[:draw_method] = :draw_dots
# 	opts[:weight] = opts[:radius] if opts.has_key? :radius
# 	n_up file_name, opts
# end

# def n_up_vertical_tri_dots(file_name, opts = {})
# 	opts[:draw_method] = :draw_vertical_tri_dots
# 	opts[:weight] = opts[:radius] if opts.has_key? :radius
# 	n_up file_name, opts
# end

# def n_up_horizontal_tri_dots(file_name, opts = {})
# 	opts[:draw_method] = :draw_horizontal_tri_dots
# 	opts[:weight] = opts[:radius] if opts.has_key? :radius
# 	n_up file_name, opts
# end

# def n_up_horizontal_fib_dots(file_name, opts = {})
# 	opts[:draw_method] = :draw_horizontal_fib_dots
# 	opts[:weight] = opts[:radius] if opts.has_key? :radius
# 	n_up file_name, opts

# end

# def n_up_vertical_fib_dots(file_name, opts = { } )
# 	opts[:draw_method] = :draw_vertical_fib_dots
# 	opts[:weight] = opts[:radius] if opts.has_key? :radius
# 	n_up file_name, opts
# end

def print_help ( errmsg = "" )
	if !errmsg.nil? and !errmsg.to_s.empty?
		puts "Error: #{errmsg}\n\n"
	end

	puts <<-EOF

dot.rb [OPTION] ... FILENAME

-h, --help:
	Show help.

-r, --rows:
	Number of rows to split the page into.  Default is 1.

-l, --columns:
	Number of columns to split the page into.  Default is 2.

-n, --numpages:
	Number of pages to create.  Default is 1.

-w, --weight:
	The size, in pt (1/72"), should each dot/line be drawn.  Default is 0.5.

-s, --spacing:
	How far apart, in pt (1/72"), should the dots/lines be apart.  Default is 13.5.

-c, --colour:
	The colour, in hex RGB value, of the dots/lines to be drawn.  Default is "DDDDDD".

-t, --type:
	The type of paper to be drawn.  Here are the supported types:

		dots 		Dots in a square grid pattern
		hrule 		Horizontally ruled
		vrule 		Vertically ruled
		grid 		Square grid
		htridots 	Dots in a horizontally-aligned triangle grid pattern 
		vtridots 	Dots in a vertically-aligned triangle grid pattern 
		hfibdots 	Horizontally-aligned dots in Fibonacci sequence (EXPERMENTAL)
		vfibdots 	Vertically-aligned dots in Fibonacci sequence (EXPERMENTAL)

	Default is "dots"

--pagewidth:
	The page width in pt (1/72").

--pageheight:
	The page height in pt (1/72").

-v, --verbose:
	Turn on debug messages.
	
EOF

end


opts = GetoptLong.new(
	[ '--help', '-h', GetoptLong::NO_ARGUMENT ],
	[ '--margin', '-m', GetoptLong::REQUIRED_ARGUMENT ],
	[ '--rows', '-r', GetoptLong::REQUIRED_ARGUMENT ],
	[ '--columns',  '-l', GetoptLong::REQUIRED_ARGUMENT ],
	[ '--pagewidth',  GetoptLong::REQUIRED_ARGUMENT ],
	[ '--pageheight', GetoptLong::REQUIRED_ARGUMENT ],
	[ '--numpages', '-n', GetoptLong::REQUIRED_ARGUMENT ],
	[ '--weight', '-w', GetoptLong::REQUIRED_ARGUMENT ],
	[ '--spacing', '-s', GetoptLong::REQUIRED_ARGUMENT ],
	[ '--colour', '--color', '-c', GetoptLong::REQUIRED_ARGUMENT],
	[ '--type', '-t', GetoptLong::REQUIRED_ARGUMENT],
	[ '--verbose', '-v', GetoptLong::NO_ARGUMENT ]
)

o = {
	:horizontal => 1, 
	:vertical => 2, 
	:page_width => 612, 
	:page_height => 792, 
	:margin => 72/4, 
	:pages => 1, 
	:weight => 0.5, 
	:space => 13.5, 
	:colour => "DDDDDD", 
	:debug => false,
	:draw_method => :draw_dots }

opts.each do |opt, arg|
	case opt
	when '--help'
		print_help
		exit 0
	when '--margin'
		o[:margin] = arg.to_i
	when '--rows'
		o[:horizontal] = arg.to_i
	when '--columns'
		o[:vertical] = arg.to_i
	when '--pagewidth'
		o[:page_width] = arg.to_i
	when '--pageheight'
		o[:page_height] = arg.to_i
	when '--numpages'
		o[:pages] = arg.to_i
	when '--weight'
		o[:weight] = arg.to_i
	when '--spacing'
		o[:space] = arg.to_i
	when '--colour'
		if arg.to_s =~ /^[0-9a-fA-F]{6}$/
			o[:colour] = arg.to_s
		else
			print_help "Colour must be specified in Hex RGB value"
			exit 0
		end
	when '--type'
		case arg
		when 'dots'
			o[:draw_method] = :draw_dots
		when 'hrule'
			o[:draw_method] = :draw_horizontal_rule
		when 'vrule'
			o[:draw_method] = :draw_vertical_rule
		when 'grid'
			o[:draw_method] = :draw_grid
		when 'htridots'
			o[:draw_method] = :draw_horizontal_tri_dots
		when 'vtridots'
			o[:draw_method] = :draw_vertical_tri_dots
		when 'hfibdots'
			o[:draw_method] = :draw_horizontal_fib_dots
		when 'vfibdots'
			o[:draw_method] = :draw_vertical_fib_dots
		else
			print_help "Unrecognized type \"#{arg}\""
			exit 0
		end

	when '--verbose'
		o[:debug] = true
	else
		print_help "Unrecognized option \"#{opt}\""
		exit 0
	end
end

if ARGV.length != 1
	print_help "Missing filename argument"
	exit 0
end

file_name = ARGV.shift

n_up file_name, o
