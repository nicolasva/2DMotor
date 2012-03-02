module Motor2D
  class Group < Shape
    include AddShapes
    
    factory_alias :g
  
    def initialize (parent, *args, &block)
      @parent = parent
      @shapes = []
      if args.length>0
        take_id args
      end
      super(&block)
    end
    
    def hull_points
      @shapes.collect do |shape|
        ctm = shape.ctm
        shape.hull_points.collect do |point| 
          point.right_multiply ctm
        end
      end.flatten
    end
    
    def to_svg
      result = "<g#{common_attrs}>\n"
      @shapes.each { |shape| result << shape.to_svg }
      if @animations
        @animations.each { |animation| result << animation.to_svg }
      end
      result << "</g>\n"
    end
  end
  
  class Anchor < Group
    factory_alias :a
  
    def initialize (parent, *args, &block)
      @parent = parent
      para = args.shift
      take_id args
      @uri = para
      super(parent, id, &block)
    end
  
    def to_svg
      result = "<a xlink:href='#{@uri}'#{common_attrs}>\n"
      @shapes.each { |shape| result << shape.to_svg }
      result << "</a>\n"
    end
  end
    
  class Defs < Group
    def initialize (parent, *args, &block)
      @parent = parent
      take_id args
      para = args.shift
      @uri = para
      super(parent, id, &block)
    end
      
    def to_svg
      result = "<defs #{common_attrs}>\n"
      @shapes.each { |shape| result << shape.to_svg }
      result << "</defs>\n"
    end
    
    def hull_points
      []
    end
  end
  
end
