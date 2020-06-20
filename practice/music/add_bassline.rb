# Add a matching bassline to the lead.
#
# Concentrate on the melody/harmony/rythm.

set :random_seed, RANDOM_SEED
set :bpm, 60

live_loop :bassline do
  with_synth :subpulse do
    # Add bassline here!
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

    base_selector = [0] + [2, 4, 6].shuffle
    bases = base_selector.map { |i| notes[i] }

    accent_selector = base_selector.map do |n|
      case rand_i(4)
      when 0
        n + 4
      when 1
        n - 3
      when 2
        n - 1
      when 3
        n - 4
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
