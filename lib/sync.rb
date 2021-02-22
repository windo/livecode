# Best loop update performance:
#
# live_loop :name, sync: `cue_name do
#   <code with no sleeps>
#   ssync `interval`, `cue_name`
# end
#
# This way the loop will start on time but will wait until the ~last moment
# (for the body to be redefined) before kicking off the next run.
define :ssync do |cue_name, interval|
  sleep interval - 0.01
  return sync_bpm cue_name
end

define :ll do |name, interval, cue_name, &block|
  in_thread do
    v = sync_bpm cue_name
    live_loop name, init: v do |v|
      duration = block_duration do
        block.call(*v)
      end
      ssync cue_name, (interval - duration)
    end
  end
end
