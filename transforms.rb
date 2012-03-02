module Motor2D
  module AddTransforms

    def add_new_transform (transform, &block)
      @transforms ||= []
      @transforms << transform
      @ctm = nil
      if block_given?
        if @chained
          @chained = false
          instance_eval &block
          @chained = true
        else
          warn "Warning: direct block on transform #{transform}, ignored"
        end
      end
      self
    end

    def ctm
      @transforms ||= []
      unless @ctm
        @ctm = @transforms.inject(Matrix.I(3)) do |memo, transform|
          memo * transform.to_matrix
        end
      end
      @ctm
    end

    def matrix (*args, &block)
      add_new_transform(SVGMatrix.new(*args), &block)
    end

    def translate (*args, &block)
      add_new_transform(Translate.new(*args), &block)
    end

    def scale (*args, &block)
      add_new_transform(Scale.new(*args), &block)
    end

    def rotate (*args, &block)
      add_new_transform(Rotate.new(*args), &block)
    end

    def skewX (*args, &block)
      add_new_transform(SkewX.new(*args), &block)
    end

    def skewY (*args, &block)
      add_new_transform(SkewY.new(*args), &block)
    end
  end

  class Transform
  end

  class SVGMatrix < Transform
    def initialize (a, b, c, d, e, f)
      @a = a
      @b = b
      @c = c
      @d = d
      @e = e
      @f = f
    end

    def to_svg
      "matrix(#{@a} #{@b} #{@c} #{@d} #{@e} #{@f})"
    end
    
    def to_matrix
      Matrix[[@a, @c, @e], [@b, @d, @f], [0, 0, 1]]
    end
  end

  class Translate < Transform
    def initialize (*args)
      para = args.shift
      if para.respond_to?(:to_point)
        @tx, @ty = para.to_point.to_a
      elsif args.length==1
        @tx = para
        @ty = args.shift
      elsif args.lenght==0
        @tx = para
        @ty = nil
      else
        raise ArgumentError, "wrong number of arguments to translate()"
      end
    super()
    end

    def to_svg
      if @ty && @ty!=0
        "translate(#{@tx} #{@ty})"
      else
        "translate(#{@tx})"
      end
    end
    
    def to_matrix
      Matrix[[1, 0, @tx], [0, 1, @ty], [0, 0, 1]]
    end
  end

  class Scale < Transform
    def initialize (*args)
      case args.length
      when 2
        @sy = args[1]
      when 1
        @sy = nil
      else
        raise ArgumentError, "wrong number of arguments to scale()"
      end
      @sx = args[0]
    end

    def to_svg
      if @sy && @sx!=@sy 
        "scale(#{@sx} #{@sy})"
      else
        "scale(#{@sx})"
      end
    end

    def to_matrix
      if @sy
        Matrix[[@sx, 0, 0], [0, @sy, 0], [0, 0, 1]]
      else
        Matrix[[@sx, 0, 0], [0, @sx, 0], [0, 0, 1]]
      end
    end
  end

  class Rotate < Transform
    def initialize (*args)
      case args.length
      when 3
        @cx = args[1]
        @cy = args[2]
      when 2
        if args[1].respond_to?(:to_point)
          @cx, @cy = args[1].to_point.to_a
        else
          raise ArgumentError, "attribute 2 of 2 for rotate() is not a point"
        end
      when 1
        @cx = 0
        @cy = 0
      else
        raise ArgumentError, "wrong number of arguments to rotate()"
      end
      @rotate_angle = args[0]
    end

    def to_svg
      if @cx > 0 && @cy > 0
        "rotate(#{@rotate_angle} #{@cx} #{@cy})"
      else
        "rotate(#{@rotate_angle})"
      end
    end

    def to_matrix
      rad_angle = Math.deg2rad(@rotate_angle)
      ra_sin = Math.sin rad_angle
      ra_cos = Math.cos rad_angle
      Matrix[[ra_cos, -ra_sin, -ra_cos*@cx+ra_sin*@cy+@cx], [ra_sin, ra_cos, -ra_sin*@cx-ra_cos*@cy+@cy], [0, 0, 1]]
    end
  end

  class SkewX < Transform
    def initialize (*args)
      case args.length
      when 1
        @skew_angle = args[0]
      else
        raise ArgumentError, "wrong number of arguments to skewX()"
      end
    end

    def to_svg
      if @skew_angle
        "skewX(#{@skew_angle})"
      end
    end

    def to_matrix
      rad_angle = Math.deg2rad(@skew_angle)
      Matrix[[1, Math.tan(rad_angle), 0], [0, 1, 0], [0, 0, 1]]
    end
  end

  class SkewY < Transform
    def initialize (*args)
      case args.length
      when 1
        @skew_angle = args[0]
      else
        raise ArgumentError, "wrong number of arguments to skewY()"
      end
    end

    def to_svg
      if @skew_angle
        "skewY(#{@skew_angle})"
      end
    end
    
    def to_matrix
      rad_angle = Math.deg2rad(@skew_angle)
      Matrix[[1, 0, 0], [Math.tan(rad_angle), 1, 0], [0, 0, 1]]
    end
  end

end
