# Design a pad sound

define :pad do |n, **kwargs|
  with_synth :fm do
    play n, divisor: 0.5, depth: 5.0, **kwargs
  end
end

# --- pad track below ---

play_midi do |n, **kwargs|
  pad(n, **kwargs)
end

live_loop :pad do
  sync_bpm :tock

  pad :g3, sustain: 7
  sleep 2.0/3
  pad :d4, sustain: 7-2.0/3
  sleep 2.0/3
  pad :a4, sustain: 2
  sleep 2.0/3 + 2
  pad :g4, sustain: 2
  sleep 2
  pad :f4, sustain: 2
  sleep 2

  pad :d4, sustain: 7
  sleep 2.0/3
  pad :a4, sustain: 7-2.0/3
  sleep 2.0/3
  pad :d5, sustain: 7-4.0/3
  sleep 2.0/3

  sleep 2
end

live_loop :drum_track do
  sync_bpm :tock

  with_fx :reverb, room: 1.5 do
    with_fx :echo, phase: 1.0/3, decay: 2.0 do
      with_fx :distortion, amp: 0.7 do
        at [0] do
          sample :bd_haus
        end
      end
      at [2] do
        sample :sn_zome
      end
    end
  end
end

live_loop :tock do
  use_bpm 80

  if tick == 0 then
    sleep 1.0
    cue :tock
  end

  4.times do
    cue :tick
    sleep 1.0
  end
end
