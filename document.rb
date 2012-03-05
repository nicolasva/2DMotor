module Motor2D 
  class Document
    include AddShapes
    include AddGeometry
    include AddTransforms
  
    def initialize (width, height, &block)
      @width = width
      @height = height
      @scripts = []
      @shapes = []
      @ids = Hash.new
  
      @chained = false
      instance_eval &block
      @chained = true
    end
    
    attr_reader :width, :height
    
    def document
      self
    end
    
    def register_id (id, object)
      if @ids[id]
        warn "Repeated use of id '#{id}'"
      else
        @ids[id] = object
      end
    end
    
    def find_id (id)
      @ids[id]
    end
  
    def shape_and_parents
      if @parent.nil? then [] else @parent.shape_and_parents end << self
    end
  
    def method_missing (id, *args)
      if (obj = document.find_id(id))
        obj
      else
        super(id, *args)
      end
    end
  
  
    def to_svg
      result = ""
      result << <<-HEADER
<?xml version='1.0' encoding='utf-8'?>
<?xml-stylesheet type="text/css" href="../stylesheets/svg_css/style.css" charset="utf-8"?>
<!DOCTYPE svg PUBLIC '-//W3C//DTD SVG 1.1//EN'
         'http://www.w3.org/Graphics/SVG/1.1/DTD/svg11-basic.dtd'>
<svg xmlns='http://www.w3.org/2000/svg'
  xmlns:xlink='http://www.w3.org/1999/xlink'
  version='1.1' width='#{@width}' height='#{@height}'>
HEADER

      #result << <<-HEADER
#<?xml version='1.0' encoding='utf-8'?>
#<?xml-stylesheet type="text/css" href="../stylesheets/svg_css/style.css" charset="utf-8"?>
#<!DOCTYPE svg PUBLIC '-//W3C//DTD SVG 1.1//EN'
#         'http://www.w3.org/Graphics/SVG/1.1/DTD/svg11-basic.dtd'>
#<svg xmlns='http://www.w3.org/2000/svg'
#  xmlns:xlink='http://www.w3.org/1999/xlink'
#  version='1.1' width='#{@width}' height='#{@height}' 
#	onload='Init(evt)'
#  	onmousedown='Grab(evt)'
#  	onmousemove='Drag(evt)'
#  	onmouseup='Drop(evt)' id='svgplan'>
#	<script xlink:href="/ecmascripts/plans.es" type="text/ecmascript"/>
#HEADER

if $there_are_arrows
  result << <<-DEFS
  <defs>
    <marker id="marker-arrowhead" markerWidth="6" markerHeight="8"
      refX="4" refY="3" orient="auto">
      <path d="M 0 0 L 4 3 0 6" style="fill: none; stroke: black;"/>
    </marker>
  </defs>
  DEFS
      end
      @scripts.each { |script| result << script.to_svg }
      @shapes.each { |shape| result << shape.to_svg }
      
      result << "</svg>"
    end
  end
  
  
  # 1.0
  #<!DOCTYPE svg PUBLIC '-//W3C//DTD SVG 1.0//EN'
  #         "http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd">
  #<svg xmlns='http://www.w3.org/2000/svg'
  #    xmlns:xlink='http://www.w3.org/1999/xlink'
  #    version='1.0' width='#{@width}' height='#{@height}'>\n"
  
  # 1.2
  #<svg xmlns='http://www.w3.org/2000/svg'
  #    xmlns:xlink='http://www.w3.org/1999/xlink'
  #    version='1.2' width='#{@width}' height='#{@height}'>\n"
  
  # Tiny1.1
  #<!DOCTYPE svg PUBLIC '-//W3C//DTD SVG 1.1 Tiny//EN'
  #         'http://www.w3.org/Graphics/SVG/1.1/DTD/svg11-tiny.dtd'>
  #<svg xmlns='http://www.w3.org/2000/svg'
  #    xmlns:xlink='http://www.w3.org/1999/xlink'
  #    version='1.1' baseProfile="tiny" width='#{@width}' height='#{@height}'>\n"
  
  # Tiny1.2
  #<svg xmlns='http://www.w3.org/2000/svg'
  #    xmlns:xlink='http://www.w3.org/1999/xlink'
  #    version='1.2' baseProfile="tiny" width='#{@width}' height='#{@height}'>\n"
  
end
