require "scite/session/version"
require "rmtools"
require "scite/animation"
require "scite/window"

module SciTE
  
  class << self
    
    def run(params={})
      sh_pid = Process.spawn "scite #{params.map {|k, v| "-#{k}:\"#{v}\""}*' '} 1>/dev/null 2>/dev/null", pgroup: 0
      pid = `pgrep -P #{sh_pid}`.chomp
      #$log << pid
      pid
    end
    
    def set_title(wid, title)
      Process.spawn "#{File.dirname(__FILE__)}/../../bin/kwintag.fish -t '#{title}' -w #{wid} 1>/dev/null 2>/dev/null", pgroup: 0
    end
    
  end
  
  # Save and restore a SciTE sessions layout.
  module Session
    mattr_accessor :home, :layouts_home
    self.home = "#{ENV['HOME']}/scite"
    self.layouts_home = "#{home}/layouts"
    
    class << self
    
      # Save session
      # @ windows : Array(SciTE::Window) : Save session
      # @ layout : String : session layout yml-file name (w/o extension)
      # @ append : Boolean : add a window record to the layout yml instead of overwrite it (default: false)
      def save(windows, layout:, append: false)
        window_configs = windows.map {|win|
          {session: win.session, title: win.title, move_to: win.position}
        }
        if append
          window_configs = load_layout(layout) << window_configs
        end
          
        File.write "#{layouts_home}/#{layout}.yml", window_configs.to_yaml
      end
    
      def restore(windows: nil, layout: nil)
        if layout
          windows = load_layout(layout)
        end
        
        windows.map! {|params|
          if params.is Window
            params
          else
            Window.new params
          end
        }
        windows.each {|w|
          w.create
          sleep 0.1
        }
        windows.each &:wait
      end
      
      private
      
      def load_layout(layout)
        YAML.load read "#{layouts_home}/#{layout}.yml"
      end
    
    end
  end
end
