# Make the sound more natural and dynamic by varying volume envelopes, timing,
# bends, etc.

set :bpm, 60
set :random_seed, RANDOM_SEED
set :use_scales, [:major, :minor, :dorian, :phrygian, :lydian, :mixolydian, :locrian]

play_midi do |n|
  synth :fm, note: n
end

live_loop :lick do
  use_bpm get(:bpm)
  pat = [
    0, 2, 5,
    4, 3, 2,
    1, 2, 3,
    0,
    0, 2, 4,
    1, 3, 5,
    3, 2, 1,
    0,

    0, 3, 0, 4,
    1, 2, 0,
    2, 3, 5, 4,
    2, 1, 0,
  ]
  timing = (
    [1.0/3] * 9 +
    [1] +
    [1.0/3] * 9 +
    [1] +

    [1.0/2] * 6 +
    [1] +
    [1.0/2] * 6 +
    [1]
  )
  notes = with_random_seed get(:random_seed) do
    scale(:c, get(:use_scales).choose)
  end
  at(
    timing.inject([0]) { |m, t| m << m[-1] + t },
    pat
  ) do |t, n, i|
    synth :fm, note: notes[n]
  end
  sleep 16
end
