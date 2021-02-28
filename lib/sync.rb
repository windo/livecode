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

# Live loop with the following features:
#  * Triggers at the last possible moment (allowing the loop body to be redefined)
#  * Can deal with variable amount of sleeps or at-triggers in the loop body
# 
# The price to pay is that the sync will be triggered outside your live loop
# with the sync value passed into the loop as one of the arguments and you will
# have to specify the loop length up front.
# 
# ll :arp, 16, :bar, init: 0 do |state, sync_values|
#   sleep 10
#   at line(0, 6) do
#     play :c
#   end
#   state
# end
define :ll do |name, interval, cue_name, init: nil, &block|
  in_thread do
    sync_values = sync_bpm cue_name
    live_loop name, init: [init, sync_values], auto_cue: false do |values|
      state, sync_values = values
      duration = block_duration do
        state = block.call([state, sync_values])
      end
      sync_values = ssync(cue_name, (interval - duration))
      [state, sync_values]
    end
  end
end
