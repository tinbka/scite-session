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
    
      def save(windows, layout:)
        File.write "#{layouts_home}/#{layout}.yml", windows.map {|win|
          {session: win.session, title: win.title, move_to: win.position}
        }.to_yaml
      end
    
      def restore(windows: nil, layout: nil)
        if layout
          windows ||= YAML.load read "#{layouts_home}/#{layout}.yml"
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
    
    end
  end
end
