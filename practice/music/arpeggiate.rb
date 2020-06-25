# Create some bouncing arpeggiated chord patterns.

set :bpm, 90
set :default_nosleep, false

live_loop :arpeggios, sync_bpm: :tock do
  # Play some arpeggios here!

  sync_bpm :tick
end

# Example:
# arp :c4, :m7, [0, 1, 3, 2]
define :arp do |root, chord_name, pattern, duration: 1, amp: 1.0, nosleep: nil|
  notes = chord(root, chord_name)
  with_fx :level, amp: 0.8 do
    at line(0, duration, steps: pattern.length), pattern do |i|
      next if i == :r
      octaves = 0
      if i >= notes.length then
        octaves = i / notes.length
        i = i - octaves * notes.length
      end
      n = notes[i] + octaves * 12
      with_synth :fm do
        play n, release: 1.0, amp: amp
        play n - 12, release: 0.25, amp: amp * 1.5
      end
      with_synth :dsaw do
        play n, detune: 1.0/3, amp: 0.6 * amp, attack: 0.125, release: 1.0
      end
    end
    nosleep = get(:default_nosleep) if nosleep.nil?
    sleep duration unless nosleep
  end
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

  4.times do
    cue :tick
    sleep 1.0
  end
end
