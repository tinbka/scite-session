# Basic implementation of an animation. Could be used anywhere.
# Optimized to not do anything when it is too late to display a frame.
module Animation
  class << self
    
    def swing_easing(part)
      0.5 - Math.cos(part * Math::PI)/2
    end
      
    def perform(initial_values, target_values, frames: 40, duration: 400.0, &interpolation)
      keys = initial_values.merge(target_values).keys
      values_diff = keys.map_hash {|k| [k, target_values[k].to_f - initial_values[k].to_f]}
      
      initial_time = Time.now.to_f
      duration_ms = duration.to_f / 1000
      frame_count = frames
      wait_count = frames - 1
      
      1.upto(frame_count) {|frame_i|
        if frame_i != frame_count
          now = Time.now.to_f
          this_must_be_run_at = initial_time + duration_ms/wait_count * (frame_i - 1)
          next_must_be_run_at = initial_time + duration_ms/wait_count * frame_i
          next if now > this_must_be_run_at + 0.001
        end
        
        frame_values = keys.map_hash {|k|
          time_part = frame_i.to_f / frame_count
          [k, initial_values[k] + values_diff[k] * swing_easing(time_part)]
        }
        #$log << frame_values
        yield frame_values
        
        if frame_i != frame_count
          now = Time.now.to_f
          if now < next_must_be_run_at
            sleep next_must_be_run_at - now
          end
        end
      }
    end
  
  end
end
