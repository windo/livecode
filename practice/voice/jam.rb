# Sing along to a chord progression

set :range, [:e3, :c5]
set :use_scales, [:major, :minor, :dorian, :phrygian, :lydian, :mixolydian, :locrian]
set :bpm, 60
set :random_seed, RANDOM_SEED

with_fx :autotuner, mix: 0.0, amp: 1.0 do
  live_audio :mic
end

define :p do |notes|
  with_fx :lpf, cutoff: :c7 do
    4.times do
      notes.each do |n|
        synth :fm, note: n, attack: 0.05, release: 0.23
        synth :pulse, note: n, release: 0.25
      end
      sleep 0.25
    end
  end
end

live_loop :backing do
  use_bpm get(:bpm)
  use_random_seed get(:random_seed)

  if get(:random_seed) != get(:saved_seed) then
    tick_reset(:backing)
    set :saved_seed, get(:random_seed)
  end

  from, to = get(:range)[0], get(:range)[1]
  r = (note(from)..note(to)).to_a.choose
  s = get(:use_scales).choose
  notes = scale(r, s)

  t = tick(:backing)
  cindex = ((t / 8).floor % 2) * 4 + t % 4
  croot = (
    [0] + (0..(notes.length)).to_a.pick(3) +
    (0..(notes.length)).to_a.pick(4)
  )[cindex]
  cnotes = [notes[croot], notes[croot + 2], notes[croot + 4]]
  p cnotes
end
