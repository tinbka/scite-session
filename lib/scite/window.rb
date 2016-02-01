module KDE
  
  # Basic operations over windows in KDE.
  class Window
    class_attribute :header_height, :border_width
    self.header_height = 23
    self.border_width = 2
    
    attr_reader :title, :position, :pid
    attr_writer :title
    
    def self.find(title: nil)
      if title
        if info = `wmctrl -l -p`[/^(0x\w+) +-?\d+ (\d+) .+ #{title}$/]
          new title: title, pid: $2.to_i, wid: $1
        end
      end
    end
  
    def initialize(title: nil, pid: nil, wid: nil)
      @title, @pid, @wid = title, pid, wid
      @threads = []
    end
    
    def wait
      @threads.joins
      @threads = []
      self
    end
    
    def wid
      @wid ||= `wmctrl -l -p | grep " #@pid "`[/0x\w+/]
    end
    
    def position
      @position ||= begin
        shape = `xwininfo -id #{wid} -shape`.lines
        dimms = shape.grep(/-geometry/)[0].match(/(?<w>\d+)x(?<h>\d+)/)
        corner = shape.grep(/Corner/)[0].match(/\+(?<x>-?\d+)\+(?<y>-?\d+)/)
        {w: dimms[:w].to_i, h: dimms[:h].to_i,
          x: corner[:x].to_i - border_width, y: corner[:y].to_i - header_height}
      end
    end
    
    def position=(coords)
      coords = coords.map_hash {|k, v| [k, v.to_i]}
      if @position != coords
        @position = coords
        `wmctrl -i -r #{wid} -e 0,#{coords[:x]},#{coords[:y]},#{coords[:w]},#{coords[:h]}`
      end
    end
    
    def move(frames: 20, duration: 400.0, **coords)
      coords.reverse_merge! position
      #$log << [position, coords, {frames: frames, duration: duration}]
      Animation.perform(position, coords, frames: frames, duration: duration) {|coords|
        self.position = coords
      }
    end
    
  end
  
end

module SciTE

  # SciTE-specific operations over windows in KDE.
  class Window < KDE::Window
    attr_reader :session, :move_to
    attr_writer :session
    
    def self.find_all
      `wmctrl -l -p`.split("\n").map {|line|
        if line[/^(0x\w+) +-?\d+ (\d+) +\S+ +(.+ [-*] SciTE)$/]
          new(title: $3, pid: $2.to_i, wid: $1)
        end
      }.compact
    end
  
    def initialize(title: nil, pid: nil, wid: nil, session: nil, move_to: nil)
      @session, @move_to = session, move_to
      super title: title, pid: pid, wid: wid
    end
    
    def create(&oncreate)
      @pid ||= SciTE.run loadsession: "#{SciTE::Session.home}/#@session"
      @threads << Thread.new {
        sleep 0.2
        self.position = {w: 50, h: 20, x: 2550, y: -40}
        sleep 3 # даём вкладкам прогрузиться
        move if @move_to
        set_title if @title
        yield self if block_given?
      }
      self
    end
    
    def move(frames: 20, duration: 400.0, **coords)
      coords.reverse_merge! @move_to if @move_to
      super
    end
    
    def set_title
      SciTE.set_title wid, @title
    end
    
  end

end