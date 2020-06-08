# Add a matching lead track for the baseline.
#
# Concentrate on the melody/harmony/rythm.

set :random_seed, RANDOM_SEED
set :bpm, 60

live_loop :leads do
  with_synth :dsaw do
    # Add lead here!
  end

  sync_bpm :tock
end

# --- stock base below ---

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

live_loop :drums do
  sync_bpm :tick
  at [0, 0.5] do
    sample :bd_haus
  end

  at line(0, 1) do
    sample :drum_cymbal_open, sustain: 0.1, amp: 0.2
  end
end

define :b do |n, t|
  with_fx :distortion, amp: 0.3 do
    with_synth :fm do
      5.times do
        play n - 0.1 + rand(0.2), sustain: t * 0.75, attack: 1.0/16, release: 1.0/16
      end
    end
    with_synth :beep do
      play n, sustain: t * 0.75, attack: 1.0/16, release: 1.0/16
      play n-12, sustain: t * 0.75, attack: 1.0/16, release: 1.0/16
    end
  end
  sleep t
end

live_loop :baseline do
  sync_bpm :tock

  times = [2.0/3, 1.0/6, 1.0/6] * 4

  lick = with_random_seed get(:random_seed) do
    root = scale(:c2, :chromatic).choose
    notes = scale(root, [
      :major, :minor, :dorian, :phrygian, :lydian, :mixolydian, :locrian,
    ].choose)

    base4 = [0] + (0..8).to_a.pick(3)
    base4 = ring(*base4)
    progression = base4.each_with_index.map do |n, i|
      next_n = base4[i + 1]
      if next_n > n then
        [n, n + 1, next_n - 1]
      elsif next_n == n then
        [n, n + 1, n + 2]
      else
        [n, n - 1, next_n + 1]
      end
    end.flatten
    progression.map { |i| notes[i] }
  end

  lick.zip(times).each do |n, d|
    b(n, d)
  end
end
