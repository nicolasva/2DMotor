module Math
  def Math.square(n)
    n * n
  end
  
  def Math.deg2rad(deg)
    deg * PI / 180
  end
end

module Motor2D
  module AddGeometry
    def pt (x, y)
      Point.new(self, x, y)
    end
    
    def regularize_interval (start, length)
      if length < 0
        warn "negative width or height"
        start, length = start+length, -length
      end
      return start, length
    end
  end
  
  class Point
    def initialize (reference, x, y)
      @ref = reference
      @x = x
      @y = y
    end
    
    attr_reader :x, :y, :ref
    
    def to_point ()
      self
    end
  
    def + (arg)
      localized = arg.local(self)
      Point.new(@ref, @x+localized.x, @y+localized.y)
    end
  
    def - (arg)
      localized = arg.local(self)
      Point.new(@ref, @x-localized.x, @y-localized.y)
    end
  
    def * (arg)
      Point.new(@ref, @x*arg, @y*arg)
    end
    
    def local (reference)
      my_parents = shape_and_parents
      your_parents = reference.shape_and_parents
      my_ctm = my_parents.inject(Matrix.I(3)) { |memo, parent| parent.ctm * memo }
      your_ctm = your_parents.inject(Matrix.I(3)) { |memo, parent| parent.ctm * memo }
      new_matrix_point = your_ctm.inverse * my_ctm * to_matrix
      Point.new(reference, new_matrix_point[0,0], new_matrix_point[1,0])
    end
    
    def length (point2)
      Math.sqrt(Math.square(point2.x-@x)+Math.square(point2.y-@y))
    end
    
    def partwise_point (point2, factor)
      Point.new(nil, @x + (point2.x-@x)*factor, @y + (point2.y-@y)*factor)    
    end
    
    def midpoint (point2)
      partwise_point(point2, 0.5)
    end
    
    def norm (point2)
      l = length(point2)
      if l == 0
        warn "tried to normalize vector of length 0"
      else
        Point.new(nil, (point2.x-@x)/l, (point2.y-@y)/l)
      end
    end
  
    def rotate (angle)
      angle = Math.deg2rad(angle)
      Point.new(nil, @x*Math.cos(angle) - @y*Math.sin(angle), @x*Math.sin(angle) + @y*Math.cos(angle))
    end
    
    def to_matrix
      Matrix[[@x], [@y], [1]]
    end
    
    def right_multiply (matrix)
      transformed = matrix * to_matrix
      pt(nil, transformed[0,0], transformed[1,0])
    end
  
    def to_a
      [@x, @y]
    end

    def shape_and_parents
      if @ref then @ref.shape_and_parents else [] end
    end
  end
  
end
