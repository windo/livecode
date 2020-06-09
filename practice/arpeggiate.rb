# Create some bouncing arpeggiated chord patterns.

set :tock_length, 4

define :arp do |r, c, p, duration: 1, nosleep: false|
  notes = chord(r, c)
  at line(0, duration, steps: p.length), p do |i|
    with_synth :fm do
      play notes[i]
      play notes[i] - 12, release: 0.25
    end
    with_synth :dsaw do
      play notes[i], detune: 1.0/3, amp: 0.8
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

  l = get(:tock_length)

  at line(0, l, steps: l/2) do
    sample :bd_haus
  end
  at line(0, l, steps: l/2) + 1 do
    sample :sn_zome
  end
end

live_loop :tock do
  use_bpm 80

  if tick(:tock) == 0 then
    sleep 1.0
    cue :tock
  end

  get(:tock_length).times do
    cue :tick
    sleep 1.0
  end
end
