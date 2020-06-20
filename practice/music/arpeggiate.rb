# Create some bouncing arpeggiated chord patterns.

set :bpm, 80

define :arp do |root, chord_name, pattern, duration: 1, nosleep: false|
  notes = chord(root, chord_name)
  at line(0, duration, steps: pattern.length), pattern do |i|
    with_synth :fm do
      play notes[i], release: 1.0
      play notes[i] - 12, release: 0.25, amp: 1.5
    end
    with_synth :dsaw do
      play notes[i], detune: 1.0/3, amp: 0.6, attack: 0.125, release: 1.0
    end
  end
  sleep duration unless nosleep
end

live_loop :arpeggios, sync: :tock do
  # Play some arpeggios here!
  
  sync_bpm :tock
end

# --- backing track below ---

live_loop :drums do
  sync_bpm :tock

  at line(0, 4, steps: 2) do
    sample :bd_haus
  end
  at line(0, 4, steps: 2) + 1 do
    sample :sn_zome
  end
end

live_loop :tock do
  use_bpm get(:bpm)

  if tick(:tock) == 0 then
    sleep 1.0
    cue :tock
  end

  get(:tock_length).times do
    cue :tick
    sleep 1.0
  end
end
