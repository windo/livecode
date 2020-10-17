live_loop :ref do
  synth :pulse, note: :c3
  sleep 4
end

with_fx :autotuner, note: :c3 do |tuner|
  live_audio :mic
  live_loop :control do
    control tuner, note: [:c3, :e3, :g3].choose
    sleep 1.0
  end
end

live_audio :mic
