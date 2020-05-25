live_loop :metronome do
  cue :tick
  sample :drum_cymbal_soft , amp: 0.1, sustain: 0.2, release: 0.05
  sleep 1.0/4
end

define :p do |n|
  use_synth :prophet
  use_synth_defaults attack: 0.05
  play n
end

sync :tick
[:a4, :c5, :b4, :e5, :d5, :c5, :b4, :a4].each do |n|
  p n
  sleep 0.5
end

[:c5, :c5, :a4, :b4, :c5, :b4, :a4].each_with_index do |n, i|
  p n
  case i
  when 0
    sleep 0.25
  when 1
    sleep 0.75
  else
    sleep 0.5
  end
end
