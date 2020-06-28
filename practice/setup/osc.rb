# Wire up on OSC input to control the sound.

live_loop :osc do
  use_real_time
  value = sync "/osc:*/**"
  puts value
  sample :bd_haus
end
