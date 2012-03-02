module Motor2D
  class BentLine < Shape
    def initialize (parent, *args, &block)
      @parent = parent
      take_id args
      @x1, @y1 = take_point args
      @x2, @y2 = take_point args
      @offset = args.shift
      @spread = args.shift
      super(&block)
    end
    
    def start
      pt(@x1, @y1)
    end
    
    def goal
      pt(@x2, @y2)
    end
  
    def norm
      start.norm goal
    end
  
    def offset_point
      start.midpoint(goal) + norm.rotate(90) * @offset
    end
    
    def control_point1
      offset_point - norm * @spread
    end
    
    def control_point2
      offset_point + norm * @spread
    end
    
    def hull_points
      [start, goal, control_point1, control_point2]
    end
  
    def to_svg
      result = output_element('path', "d='M #{@x1} #{@y1} C #{control_point1.x} #{control_point1.y} #{control_point2.x} # { control_point2.y} #{@x2} #{@y2}'")
    end
  end
  
  class BentArrow < BentLine 
    def initialize (parent, *args, &block)
      super(parent, *args, &block)
      if false 
        style(:marker_end => 'url(#marker-arrowhead)')
        $there_are_arrows = true
      end
    end
    
    def to_svg
      result = super
      if true 
        stroke_width = if @style and @style[:stroke_width] 
          @style[:stroke_width]
        else
          1
        end
        norm = control_point2.norm(goal)
        backwards = goal - norm * stroke_width * 4
        offset = norm.rotate(90) * stroke_width * 3
        x1l, y1l = (backwards+offset).to_a
        x1r, y1r = (backwards-offset).to_a
        result = output_element('line', "x1='#{x1l}' y1='#{y1l}' x2='#{@x2}' y2='#{@y2}'") + output_element('line', "x1='#{x1r}'   y1='#{y1r}' x2='#{@x2}' y2='#{@y2}'")
      end    
    end
  end
  
  class LabeledCircle < Group
    def initialize (parent, *args, &block)
      @parent = parent
      take_id args
      cx, cy = take_point args
      r = args.shift
      t = args.shift
      super(parent, &block)
      circle cx, cy, r
      text(t, cx-(r/2.0), cy+(r/2.0)).font_size((r*1.4).to_i).fill(:black).stroke_width(0)
    end
    
    def tl() @shapes[0].tl end
    def tr() @shapes[0].tr end
    def tc() @shapes[0].tc end
    def bl() @shapes[0].bl end
    def br() @shapes[0].br end
    def bc() @shapes[0].bc end
    def ml() @shapes[0].ml end
    def mr() @shapes[0].mr end
    def mc() @shapes[0].mc end
  
  end
  
  class GridLine < Shape
    def initialize (parent, *args, &block)
      @parent = parent
      take_id args
      @distance = args.shift
      para = args.shift
      if para then @scale = para else @scale = 1 end
      super(&block)
    end
    
    def to_svg
      result = "<g#{common_attrs}>\n"
      0.step(document.width, @distance) do |i|
        result << "<line x1='#{i}' y1='0' x2='#{i}' y2='#{document.height}'/>"
        if @scale == 1 then result << "<text x='#{i}' y='12'>#{i}</text>" end
        result << "\n"
      end
      0.step(document.height, @distance) do |i|
        result << "<line x1='0' y1='#{i}' x2='#{document.width}' y2='#{i}'/>"
        if @scale == 1 then result << "<text x='0' y='#{i}'>#{i}</text>" end
        result << "\n"
      end
      result << "</g>\n"
    end
  end
  
  class Star < Shape
    def initialize (parent, *args, &block)
      @parent = parent
      take_id args
      @n = args.shift
      @cx, @cy = take_point args
      @r = args.shift
      if args.length > 0 then @offset = Math.deg2rad(args.shift) else @offset = 0 end
      angle = 2*Math::PI/@n
      @inr = @r * Math.cos(angle) / Math.cos(angle/2)
      @outpoints = []
      @inpoints = []
      @points = []
      @n.times do |i|
        @outpoints[i] = [@cx + @r * Math.cos(i*angle-@offset), @cy + @r * Math.sin(i*angle-@offset)]
        @inpoints[i] = [@cx + @inr * Math.cos(i*angle+angle/2-@offset), @cy + @inr * Math.sin(i*angle+angle/2-@offset)]
        @points << @outpoints[i]
        @points << @inpoints[i]
      end
      super(&block)
    end
    
    def hull_points
      @points
    end
    
    def to_svg
      points = @points.join(" ")
      result = output_element('polygon', "points='#{points}'")
    end
  end
  
  class RegularPolygon < Star
    def initialize (parent, *args, &block)
      super(parent, *args, &block)
      @points = []
      @points = @outpoints.dup
    end
    
    def hull_points
      @points
    end
  end
  
  class Balloon < Shape
    def initialize (parent, *args, &block)
      @parent = parent
      take_id args
      @xs, @ys = take_point args
      @xg, @yg = take_point args
      @rx = args.shift
      para = args.shift
      if para then @ry = para else @ry = @rx*0.75 end
      d = ((@rx**2 + @ry**2)**0.5)/10
      if @xg > @xs
        @yg1 = @yg - d
        @yg2 = @yg + d
        if @yg < @ys
          @xg1 = @xg - d
          @xg2 = @xg + d
        else
          @xg1 = @xg + d
          @xg2 = @xg - d
        end
      else
        @yg1 = @yg + d
        @yg2 = @yg - d
        if @yg < @ys
          @xg1 = @xg - d
          @xg2 = @xg + d
        else
          @xg1 = @xg + d
          @xg2 = @xg - d
        end
      end
        
      @sweep = 1
      super(&block)
    end
    
    def hull_point
    end
    
    def to_svg
      result = output_element('path', "d='M #{@xs} #{@ys} L #{@xg1} #{@yg1} A #{@rx} #{@ry} 0 1 #{@sweep} #{@xg2} #{@yg2} Z'")
    end
  end
  
  class Bezier3d < Shape
    def initialize (parent, *args, &block)
      @parent = parent
      take_id args
      @m = []
      @m << args.shift
      @m << args.shift
      @m = @m.join(" ")
      @points = args.join(" ")
      super(&block)
    end
    
    def hull_points
    end
    
    def to_svg
      result = output_element('path', "d='M #{@m} C #{@points}'")
    end
  end
  
  class Arrow < Line
    def initialize (parent, *args, &block)
      super(parent, *args, &block)
      style(:marker_end => 'url(#marker-arrowhead)')
      $there_are_arrows = true
    end
  end
  
  class RotatedText < Text
    def initialize (*args, &block)
      angle = args.pop
      super(*args, &block)
      rotate angle, @x, @y
    end
  end
  
  class Repeat < Group
    def initialize (parent, *args, &block)
      para = args.shift
      if para.respond_to?(:to_svg)
        @repeated_id = para.id
        para = args.shift
      end
      @counter = para
      @x, @y = take_point args
      super(parent, &block)
      if @repeated_id and @shapes.length > 0
      elsif @shapes.length > 0
        @repeated_shapes = @shapes
        @shapes = []
      elsif @repeated_id
        x, y = @x, @y
        @counter.times do |i|
          use(@repeated_id) {
            translate((x * i), (y * i))
          }
        end   
      end
      
      @block = block
    end
  end
  
end
