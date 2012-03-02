class String
  def xml_escape ()
    gsub(/[<&"']/) do |match|
      case match
      when '&': '&amp;'
      when '<': '&lt;'
      when '"': '&quot;'
      when "'": '&apos;'
      end
    end
  end
end

module Motor2D
  module AddShapes
    def add_new_shape (shape)
      @shapes << shape
      shape
    end
  
    def AddShapes.factory_alias (new_method, old_method)
      alias_method new_method, old_method
    end
  end
  
  class Shape
    include AddStyle
    include AddGeometry
    include AddTransforms
    
    def initialize (&block)
      @chained = true
      if block_given?
        @chained = false
        instance_eval &block
        @chained = true
      end
    end
  
    attr_reader :id
    
    def Shape.class_name_to_method_name (class_name)
      method_name = class_name.sub(/Motor2D::/,"")
      method_name[0,1] = method_name[0,1].downcase
      method_name.gsub!(/./) do |match|
        match == match.downcase ? match : '_'+match.downcase
      end
      method_name
    end
  
    def Shape.inherited (subclass)
      factory_method_name = Shape.class_name_to_method_name(subclass.name)
      unless AddShapes.method_defined? factory_method_name.to_sym
        AddShapes.module_eval %{
          def #{factory_method_name} (*args, &block)
            add_new_shape #{subclass.name}.new(self, *args, &block)
          end
        }
      end
      super(subclass)
    end
    
    def Shape.factory_alias (new_method)
      old_method = Shape.class_name_to_method_name(self.name).to_sym
      unless AddShapes.method_defined? old_method
        warn "old factory method not yet defined!"
      end
      AddShapes.factory_alias new_method, old_method
    end
    
    def take_id (args)
      if args.length > 0 && args[0].kind_of?(Symbol)
        @id = args.shift
        register_id @id
      end
    end
    
    def take_point (args)
      para = args.shift
      if para.respond_to?(:to_point)
        x, y = para.to_point.local(self).to_a
      else
        x = para
        y = args.shift
      end
      unless x and y
        raise ArgumentError, "point required (#{x},#{y})"
      end
      return x, y
    end
    
    def shape_and_parents
      if @parent.nil? then [] else @parent.shape_and_parents end << self
    end
    
    def document
      @parent.document if @parent
    end
    
    def register_id (id)
      document.register_id(id, self)
    end
    
    def bounding_box
      hull = hull_points
      xs = hull.collect { |point| point.x }
      ys = hull.collect { |point| point.y }
      xmax = xs.max
      xmin = xs.min
      ymax = ys.max
      ymin = ys.min
      [xmin, ymin, xmax-xmin, ymax-ymin]
    end
    
    def method_missing (id, *args)
      if (obj = document.find_id(id))
        obj
      else
        super(id, *args)
      end
    end
    
    def common_attrs()
      id_attribute = if @id then ' id="' + @id.to_s + '"' else '' end
      event_attrs = if @event then @event.to_attributes else '' end
      style_attrs = if @style then @style.to_attributes else '' end
      transform_attrs = ""
      if @transforms
        transform_attrs = ' transform="'
        @transforms.each do |tr|
          transform_attrs << tr.to_svg + ' '
        end
        transform_attrs.rstrip!
        transform_attrs << '"'
      end
      id_attribute + event_attrs + style_attrs + transform_attrs
    end
    
    def output_element(element, tag)
      if @animations
        result = "<#{element} #{tag}#{common_attrs}>\n"
        @animations.each {|animation| result << animation.to_svg}
        result << "</#{element}>\n"
      else
        result = "<#{element} #{tag}#{common_attrs}/>\n"
      end
    end
  end
  
  class Rect < Shape
    def initialize (parent, *args, &block)
      @parent = parent
      take_id args
      @x, @y = take_point args
      @width = args.shift
      @height = args.shift
      para = args.shift
      if para
        @rx = para.abs
        para = args.shift
        if para
          @ry = para.abs
        else
          @ry = @rx    #@@@@ delay this
        end
      end
      @x, @width = regularize_interval(@x, @width)
      @y, @height = regularize_interval(@y, @height)
      super(&block)
    end
    
    # attachment points for arrows,...
    def t() @y end
    def b() @y+@height end
    def l() @x end
    def r() @x+@width end
    def cx() @x+@width/2 end
    def cy() @y+@height/2 end
    def tl() pt(l,t) end
    def tr() pt(r,t) end
    def tc() pt(cx,t) end
    def bl() pt(l,b) end
    def br() pt(r,b) end
    def bc() pt(cx,b) end
    def ml() pt(l,cy) end
    def mr() pt(r,cy) end
    def mc() pt(cx,cy) end
    
    # hull points for bounding box
    def hull_points
      [tl, tr, bl, br]
    end
    
    def to_svg
      style_element = "width='#{@width}' height='#{@height}'"
      style_element << " x='#{@x}'" if @x
      style_element << " y='#{@y}'" if @y
      style_element << " rx='#{@rx}'" if @rx
      style_element << " ry='#{@ry}'" if @ry
      result = output_element('rect', style_element)
    end
  end
  
  class Circle < Shape
    def initialize (parent, *args, &block)
      @parent = parent
      take_id args
      para = args.shift
      if para.respond_to?(:to_point)
        @cx, @cy = para.to_point.to_a
      else
        @cx = para
        para = args.shift
        if para
          @cy = para
        else
          @r = @cx
          @cx, @cy = 0, 0
        end
      end
      para = args.shift    #@@@@ test circtle with radius only!
      @r = para
      super(&block)
    end
    
    #attachment points for arrows,...
    def t() [@cy-@r,@cy+@r].min end
    def b() [@cy-@r,@cy+@r].max end
    def l() [@cx-@r,@cx+@r].min end
    def r() [@cx-@r,@cx+@r].max end
    def tl() pt(@cx-(@r*Math.sqrt(2)/2),@cy-(@r*Math.sqrt(2)/2)) end
    def tr() pt(@cx+(@r*Math.sqrt(2)/2),@cy-(@r*Math.sqrt(2)/2)) end
    def tc() pt(@cx,t) end
    def bl() pt(@cx-(@r*Math.sqrt(2)/2),@cy+(@r*Math.sqrt(2)/2)) end
    def br() pt(@cx+(@r*Math.sqrt(2)/2),@cy+(@r*Math.sqrt(2)/2)) end
    def bc() pt(@cx,b) end
    def ml() pt(l,@cy) end
    def mr() pt(r,@cy) end
    def mc() pt(@cx,@cy) end
    #end
    # hull points for bounding box
    def approximate_tc() pt(@cx,@cy-@r*2*Math.sqrt(3)/3) end
    def approximate_tl() pt(l,@cy-@r*Math.sqrt(3)/3) end
    def approximate_tr() pt(r,@cy-@r*Math.sqrt(3)/3) end
    def approximate_bc() pt(@cx,@cy+@r*2*Math.sqrt(3)/3) end
    def approximate_bl() pt(l,@cy+@r*Math.sqrt(3)/3) end
    def approximate_br() pt(r,@cy+@r*Math.sqrt(3)/3) end
    
    def hull_points
      [approximate_tc, approximate_bc, approximate_tl, approximate_tr, approximate_bl, approximate_br]
    end
    #end
    
    def to_svg
      result = output_element('circle',"cx='#{@cx}' cy='#{@cy}' r='#{@r}'")
      end
  end
      
  class Ellipse < Shape
    def initialize (parent, *args, &block)
      @parent = parent
      take_id args
      @cx, @cy = take_point args
      para = args.shift
      if para
        @rx = para
        @ry = args.shift
      else
        @rx, @ry = @cx, @cy
        @cx, @cy = 0, 0
      end
      super(&block)
    end
    
    # attachment points for arrows,...
    def t() [@cy-@ry,@cy+@ry].min end
    def b() [@cy-@ry,@cy+@ry].max end
    def l() [@cx-@rx,@cx+@rx].min end
    def r() [@cx-@rx,@cx+@rx].max end
    def tl() pt(@cx-(@rx*Math.sqrt(2)/2),@cy-(@rx*Math.sqrt(2)/2)*@ry/@rx) end
    def tr() pt(@cx+(@rx*Math.sqrt(2)/2),@cy-(@rx*Math.sqrt(2)/2)*@ry/@rx) end
    def tc() pt(@cx,t) end
    def bl() pt(@cx-(@rx*Math.sqrt(2)/2),@cy+(@rx*Math.sqrt(2)/2)*@ry/@rx) end
    def br() pt(@cx+(@rx*Math.sqrt(2)/2),@cy+(@rx*Math.sqrt(2)/2)*@ry/@rx) end
    def bc() pt(@cx,b) end
    def ml() pt(l,@cy) end
    def mr() pt(r,@cy) end
    def mc() pt(@cx,@cy) end
    
   # hull points for bounding box
    def approximate_tc() pt(@cx,@cy-(@rx*2*Math.sqrt(3)/3)*@ry/@rx) end
    def approximate_tl() pt(l,@cy-(@rx*Math.sqrt(3)/3)*@ry/@rx) end
    def approximate_tr() pt(r,@cy-(@rx*Math.sqrt(3)/3)*@ry/@rx) end
    def approximate_bc() pt(@cx,@cy+(@rx*2*Math.sqrt(3)/3)*@ry/@rx) end
    def approximate_bl() pt(l,@cy+(@rx*Math.sqrt(3)/3)*@ry/@rx) end
    def approximate_br() pt(r,@cy+(@rx*Math.sqrt(3)/3)*@ry/@rx) end
    
    def hull_points
      [approximate_tc, approximate_bc, approximate_tl, approximate_tr, approximate_bl, approximate_br]
    end
    #end  
    def to_svg
      result = output_element('ellipse', "cx='#{@cx}' cy='#{@cy}' rx='#{@rx}' ry='#{@ry}'")
    end
  end
  
  class Line < Shape
    def initialize (parent, *args, &block)
      @parent = parent
      take_id args
      @x1, @y1 = take_point args
      @x2, @y2 = take_point args
      super(&block)
    end
    
    def start
      pt(@x1, @y1)
    end
    
    def goal
      pt(@x2, @y2)
    end
    
    # hull points for bounding box
    def hull_points
      [start, goal]
    end
    
    def to_svg
      result = output_element('line', "x1='#{@x1}' y1='#{@y1}' x2='#{@x2}' y2='#{@y2}'")
      end
  end
  
  class Polyline < Shape
    def initialize (parent, *args, &block)
      @parent = parent
      take_id args
      @points = []
      while args.length > 0 do
        @points << take_point(args).to_a
      end
      super(&block)
    end
    
    # hull points for bounding box
    def hull_points
      @points
    end
    
    def to_svg
      result = output_element('polyline', "points='#{@points.join(" ")}'")
      result
    end
  end
  
  class Polygon < Shape
    def initialize (parent, *args, &block)
      @parent = parent
      take_id args
      @points = []
      while args.length > 0 do
        @points << take_point(args).to_a
      end
      super(&block)
    end
    
    # hull points for bounding box
    def hull_points
      @points
    end
      
    def to_svg
      result = output_element('polygon', "points='#{@points.join(" ")}'")
    end
  end
  
  class Path < Shape
=begin
      names = %w[M m L l C c S s Q q T t Z z H h V v A a]
      names.each { |name|
        class_eval(<<-DEF)
          def #{name} (*args)
            while args.length > 0
              @data << take_point(args).to_a
            end
          end
        DEF
      }
=end
    def initialize (parent, *a, &block)
      @parent = parent
      take_id a
      @data = []
      super(&block)
      if a.length > 0 then @points = a.join(" ") end
  
      alias M path_cmd
      alias m path_cmd
      alias L path_cmd
      alias l path_cmd
      alias C path_cmd
      alias c path_cmd
      alias S path_cmd
      alias s path_cmd
      alias Q path_cmd
      alias q path_cmd
      alias T path_cmd
      alias t path_cmd
    end
    
    def current_method
      caller.first[/:in \`(.*?)\'\z/, 1]
    end
    
    def path_cmd (*args)
      @data << current_method
      if /[ZzHhVvAa]/ =~ current_method
        #@@@ need other treatment
      end
      while args.length > 0
        @data << take_point(args).to_a
      end
    end
  
    def to_svg
      if @points
        result = output_element('path', "d='#{@points}'")
      else
        data = @data.join(" ")
        result = output_element('path', "d='#{data}'")
      end
      result
    end
  end
  
  # this is very crude, just for extremely simple texts
  class Text < Shape
    def initialize (parent, text, *args, &block)
      @parent = parent
      @text = text
      take_id args
      @x, @y = take_point args
      super(&block)
    end
    
    # hull points for bounding box
    def hull_points
    end
    
    def to_svg
  #   result = output_element('text', "x='#{@x}' y='#{@y}'#{xml_escape(@text)}")
      result = "<text x='#{@x}' y='#{@y}'#{common_attrs}>#{@text.xml_escape}</text>\n"
    end
  end
  
  class Image < Rect
    def initialize (parent, *args, &block)
      take_id args
      @uri = args.pop
      super(parent, *args, &block)
    end
    
    # hull points for bounding box
    def hull_points
    end
    
    def to_svg
      result = output_element('image', "x='#{@x}' y='#{@y}' height='#{@height}' width='#{@width}' xlink:href='#{@uri}'")
    end
  end
  
  class Use < Shape
    def initialize (parent, *args, &block)
      @parent = parent
      @id = args.shift
      @used_id, @id = @id, nil  #@@@@@@
      para = args.shift
      if para.respond_to?(:to_point)
        @x, @y = para.to_point.to_a
      else
        @x = para
        @y = args.shift
      end
      @width = args.shift
      @height = args.shift
      @uri = args.shift
  
      super &block
    end
    
    def to_svg
      result = output_element('use', "xlink:href='##{@used_id}'")
    end
  end
  
end
