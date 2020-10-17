define :example do |**kwargs|
  dir = "/home/siim/media/samples/legowelt/DX-FILES"
  sample dir, "AmbientGlassPadz", **kwargs
end

define :design do |rate: 1.0, **kwargs|
  n = hz_to_midi(60.0 / rate) + note(:c2)
  synth :fm, note: n
end

live_loop :ambiance do
  with_fx :sound_out, channel: 2, amp: 0 do
    example # rate: [0.5, 1.0, 2.0].choose, pan: rand() - 0.5
  end
  with_fx :sound_out, channel: 3 do
    design
  end
  sleep 2.0
end
