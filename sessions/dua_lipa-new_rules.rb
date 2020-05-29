
# soft base, cymbals, shakers
# synth chords, flicks

# short wind instrument pops
# slides on low base
# string strikes (piccolo) counting up
# synth chords
# drummroll

$cmap = {
  :am => chord(:a4, :m),
  :f => chord(:f4, :M),
  :g => chord(:g4, :M),
}

live_loop :metronome do
  use_bpm 70
  cue :tick
  sleep 1.0
  sleep 1e-6
end

def hh(s, a = 1.0)
  sample :drum_cymbal_pedal, amp: a, sustain: 0, release: 0.1
  sleep s
end

live_loop :drums do
  sync_bpm :tick
  sample :bd_boom
  hh 1.0/3, 1.5
  hh 0.75-1.0/3
  hh 0.25
end

live_loop :synth do
  sync_bpm :tick
  use_synth :prophet
  play_chord $cmap[:am]
  sleep 3.0/4
  play_chord $cmap[:am]
  sleep 3.0/4
  play_chord $cmap[:am]
  sleep 2
end
