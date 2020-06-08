#Harmonize the melody!

set :random_seed, RANDOM_SEED
set :bpm, 60

define :p do |r, c|
  notes = chord(r, c)
  with_synth :subpulse do
    play_chord notes
  end
  with_synth :fm do
    play_chord notes-12, amp: 0.7
    play_chord notes-24, amp: 1.0
  end
  with_synth :sine do
    play_chord notes+12, release: 0.25, amp: 0.5
    play_chord notes+24, release: 0.125, amp: 0.25
  end
end

live_loop :chords do
  with_synth :subpulse do
    # Add some chords here!
  end

  sync_bpm :tock
end

# --- backing track below ---

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

live_loop :lead do
  sync_bpm :tock

  lick = with_random_seed get(:random_seed) do
    root = scale(:c, :chromatic).choose
    notes = scale(root, [
      :major, :minor, :dorian, :phrygian, :lydian, :mixolydian, :locrian,
    ].choose)

    base_selector = (
      [0] + (1..7).to_a.shuffle.slice(0, 3) +
      [0, 4].pick + (1..7).to_a.shuffle.slice(0, 3) +
      [0] + (1..7).to_a.shuffle.slice(0, 3) +
      [0, 4].pick + (1..7).to_a.shuffle.slice(0, 3)
    )
    bases = base_selector.map { |i| notes[i] }

    accent_selector = base_selector.map do |n|
      case rand_i(2)
      when 0
        n + rand_i(3) + 1
      when 1
        n - rand_i(3) - 1
      end
    end
    accents = accent_selector.map { |i| notes[i] }

    bases.zip(accents).flatten
  end
  
  sleeps = ring 1.0/3, 2.0/3
  amps = ring 1.0, 0.7
  with_synth :prophet do
    lick.each do |n|
      at [0, 0.5], [0, 12] do |d|
        play n + d, amp: amps[tick(:amps)]
      end
      sleep sleeps[tick(:sleeps)]
    end
  end
end

live_loop :drums do
  sync_bpm :tock

  at [0, 2] do
    sample :bd_haus
  end
  at [1, 3] do
    sample :sn_zome
  end
end
