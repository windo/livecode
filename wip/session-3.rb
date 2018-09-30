live_loop :metronome do
  use_bpm 60
  cue :tick
  sleep 1
  sleep 1e-6
end

live_loop :beat do
  sync_bpm :tick
  sample :bd_haus
  sleep 1.0/3
  sample :bd_haus
end

def go(n)
  n = n[0]
  nn = chord(n, :minor)
  puts nn
  play_chord nn
  sleep 1.0/2
end

live_loop :synth do
  sync_bpm :tick

  use_synth :pulse
  use_synth_defaults amp: 0.5, attack: 0, decay: 0, release: 0.01, sustain: 0.5

  4.times do
    go(pick(scale(:a2, :minor_pentatonic)))
  end
end
