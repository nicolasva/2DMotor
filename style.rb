class Module
    alias charesc_old_const_missing const_missing
    
    def const_missing (const)
      const_string = const.to_s
      if const_string =~ /^H[a-fA-F0-9]{3}([a-fA-F0-9]{3})$/
        const_string.sub(/^H/, '#')
      else
        charesc_old_const_missing const
      end
    end
end

module Motor2D
  module AddStyle
    @@StyleProperties = [
      :text,
      :onclick,
      :font, 
      :font_family,
      :id,
      :class, 
      :font_size, 
      :font_size_adjust, 
      :font_stretch, 
      :font_style, 
      :font_variant, 
      :font_weight, 
      :direction, 
      :letter_spacing, 
      :text_decoration, 
      :unicode_bidi, 
      :word_spacing, 
      :clip, 
      :color, 
      :cursor, 
      :display, 
      :overflow, 
      :visibility, 
      :clip_path, 
      :clip_rule, 
      :mask, 
      :opacity, 
      :enable_background, 
      :filter, 
      :flood_color, 
      :flood_opacity, 
      :lighting_color, 
      :stop_color, 
      :stop_opacity, 
      :pointer_events, 
      :color_interpolation, 
      :color_interpolation_filters, 
      :color_profile, 
      :color_rendering, 
      :fill, 
      :fill_opacity, 
      :fill_rule, 
      :image_rendering, 
      :marker, 
      :marker_end, 
      :marker_mid, 
      :marker_start, 
      :shape_rendering, 
      :stroke, 
      :stroke_dasharray, 
      :stroke_dashoffset, 
      :stroke_linecap, 
      :stroke_linejoin, 
      :stroke_miterlimit, 
      :stroke_opacity, 
      :stroke_width, 
      :text_rendering, 
      :alignment_baseline, 
      :baseline_shift, 
      :dominant_baseline, 
      :glyph_orientation_horizontal, 
      :glyph_orientation_vertical, 
      :kerning, 
      :text_anchor, 
      :writing_mode
    ]
    
    def style (property_hash = {}, &block)
      @style ||= Style.new
      
      property_hash.each do |property, value|
        set_style_property property, value
      end
      
      if block_given?
        if @chained
          instance_eval &block
        else
          @style.instance_eval &block
        end
      end
      if @chained then self else @style end
    end
  
    def set_style_property (property, value, &block)
      if @@StyleProperties.member?(property)
        if kind_of? Style
          self[property] = value
        else
          @style ||= Style.new
          @style[property] = value
        end
      else
        warn "Warning: unknown style property '#{property}', ignored"
      end
      
      if block_given?
        if @chained
          @chained = false
          instance_eval &block
          @chained = true
        else
          warn "Warning: direct block on style property #{property}, ignored"
        end
      end
      self
    end
  
    def fill (value, &block)
      set_style_property :fill, value, &block
    end

    def onclick (value, &block)	
      set_style_property :onclick, value, &block
    end
 
    def id (value, &block)
      set_style_property :id, value, &block
    end

    def class (value, &block)
      set_style_property :id, value, &block
    end
    
    def text (value, &block)
      set_style_property :id, value, &block
    end
 
    def stroke (value, &block)
      set_style_property :stroke, value, &block
    end
  
    def stroke_width (value, &block)
      set_style_property :stroke_width, value, &block
    end
  
    def font_size (value, &block)
      set_style_property :font_size, value, &block
    end
  
    def font_weight (value, &block)
      set_style_property :font_weight, value, &block
    end
  
    def font_family (value, &block)
      set_style_property :font_family, value, &block
    end
  
    def marker_end (value, &block)
      set_style_property :marker_end, value, &block
    end
  
    def text_anchor (value, &block)
      set_style_property :text_anchor, value, &block
    end
  end
  
  class Style
    include AddStyle
  
    def initialize (property_hash = {})
      @properties = {}
    end
  
    def [] (property)
      @properties[property]
    end
  
    def []= (property, value)
      @properties ||= {}
      @properties[property] = value
    end
  
    def style (a)
      raise NoMethodError, 'style method not available on Style object'
    end
  
    def to_attributes
      result = ""
      @properties.each do |property, value|
        result << ' ' + property.to_s.gsub(/_/, '-') + '="' + value.to_s + '"'
      end
      result
    end
  end
  
end
