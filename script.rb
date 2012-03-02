module Motor2D
  module AddScripts
    def add_new_script (script)
      @scripts << script
      script
    end
    
    def script (*args)
      add_new_script Script.new(*args)
    end
    def script_uri (*args)
      add_new_script ScriptURI.new(*args)
    end
  end
  
  module AddEvents
    @@EventProperties = [
      :onfocusin, :onfocusout, :onactivate,
      :onclick, :onmousedown, :onmouseup, :onmouseover, :onmousemove, :onmouseout,
      :onload, :onunload, :onabort, :onerror, :onresize, :onscroll, :onzoom, :onbegin, :onend, :onrepeat
    ]
    
    def event (property_hash = {}, &block)
      @event ||= Event.new
      
      property_hash.each do |property, value|
        set_event_property property, value
      end
      
      if block_given?
        if @chained
          instance_eval &block
        else
          @event.instance_eval &block
        end
      end
      if @chained then self else @event end
    end
    
    def set_event_property (property, value, &block)
      if @@EventProperties.member?(property)
        if value[-1, 1] == ')' then value.insert(-2, ', evt') else value.insert(-1, ' evt') end
        if kind_of? Event
          self[property] = value
        else
          @event ||= Event.new
          @event[property] = value
        end
      else
        warn "Warning: unknown event property '#{property}', ignored"
      end
      
      if block_given?
        if @chained
          @chained = false
          instance_eval &block
          @chained = true
        else
          warn "Warning: direct block on event property #{property}, ignored"
        end
      end
      self
    end
    
    def onfocusin (value, &block)
      set_event_property :onfocusin, value, &block
    end
    
    def onfocusout (value, &block)
      set_event_property :onfocusout, value, &block
    end
    
    def onactivate (value, &block)
      set_event_property :onactivate, value, &block
    end
    
    def onclick (value, &block)
      set_event_property :onclick, value, &block
    end
    
    def onmousedown (value, &block)
      set_event_property :onmousedown, value, &block
    end
    
    def onmouseup (value, &block)
      set_event_property :onmouseup, value, &block
    end
    
    def onmouseover (value, &block)
      set_event_property :onmouseover, value, &block
    end
    
    def onmousemove (value, &block)
      set_event_property :onmousemove, value, &block
    end
    
    def onmouseout (value, &block)
      set_event_property :onmouseout, value, &block
    end
    
    def onload (value, &block)
      set_event_property :onload, value, &block
    end
    
    def onunload (value, &block)
      set_event_property :onunload, value, &block
    end
    
    def onabort (value, &block)
      set_event_property :onabort, value, &block
    end
    
    def onerror (value, &block)
      set_event_property :onerror, value, &block
    end
    
    def onresize (value, &block)
      set_event_property :onresize, value, &block
    end
    
    def onscroll (value, &block)
      set_event_property :onscroll, value, &block
    end
    
    def onzoom (value, &block)
      set_event_property :onzoom, value, &block
    end
    
    def onbegin (value, &block)
      set_event_property :onbegin, value, &block
    end
    
    def onend (value, &block)
      set_event_property :onend, value, &block
    end
    
    def onrepeat (value, &block)
      set_event_property :onrepeat, value, &block
    end
  end
  
  class Script
    include AddScripts
    
    def initialize (*args)
      @function = args.to_s.xml_escape
      @functions ||= ""
      @functions << @function
    end
    
    def to_svg
      result = "<script type='text/ecmascript'>\n"
      result << @functions
      result << "</script>\n"
    end
  end
  
  class ScriptURI
    include AddScripts
    
    def initialize (*args)
      @uri = args.to_s
    end
    
    def to_svg
      result = "<script type='text/ecmascript' xlink:href='#{@uri}' />\n"
    end
  end
  
  class Event
    include AddEvents
    
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
      raise NoMethodError, 'style method not available on Event object'
    end
    
    def to_attributes
      result = ""
      @properties.each do |property, value|
        result << " #{property.to_s.gsub(/_/, '-')}='#{value}'"
      end
      result
    end
  end
  
end
