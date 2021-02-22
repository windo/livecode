# Voice warmup exercise
set :range, [:e3, :c5]
set :use_scales, [:major, :minor, :dorian, :phrygian, :lydian, :mixolydian, :locrian]
set :bpm, 60
use_random_seed Time::now.to_i

define :p do |n, **kwargs|
  synth :fm, note: n, attack: 0.05, **kwargs
  synth :pulse, note: n, **kwargs
end

with_fx :autotuner, mix: 0.0 do
  live_audio :mic
end

live_loop :prompts do
  use_bpm get(:bpm)

  from, to = get(:range)[0], get(:range)[1]
  r = (note(from)..note(to)).to_a.choose
  s = get(:use_scales).choose
  notes = scale(r, s)
  puts s
  keyboard notes
  puts notes

  2.times do
    at line(0, 1, steps: notes.length) do |_, i|
      p notes[i], release: 0.2
    end
    sleep 1.0
  end

  sleep 1.0

  4.times do
    phrase = notes.pick(3)
    keyboard phrase

    4.times do
      at line(0, 1, steps: phrase.length) do |_, i|
        p phrase[i], release: 0.5
      end
      sleep 3.0
    end
  end
end
