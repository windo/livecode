# Connect a hardware or software MIDI device!

define :sound do |n|
  port = nil
  with_midi_defaults port: port, channel: 0 do
    midi n
  end
end

live_loop :synth do
  s = shuffle(scale(:c, :minor_pentatonic))
  s.each do |n|
    sound(n)
    sleep 0.5
  end
end
