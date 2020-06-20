# Match the muffled melody in your own live loop.

set :bpm, 120
set :use_scales, [:major, :minor, :dorian, :phrygian, :lydian, :mixolydian]
set :bars, 2
set :random_seed, RANDOM_SEED

define :p do |n|
  with_synth :fm do
    play n
  end
end

live_loop :match do
  # Match the meldoy here!

  sync_bpm :tock
end

# --- random muffled melody below ---
#
with_random_seed get(:random_seed) do
  set :pick_scale, scale(
    :c4, get(:use_scales).choose, num_octaves: 1)
end

live_loop :tock do
  use_bpm get(:bpm)

  if tick(:tock) == 0 then
    sleep 1.0
    cue :tock
  end

  4.times do
    cue :tick
    sleep 1
  end
end

live_loop :melody do
  sync_bpm :tock
  with_random_seed get(:random_seed) do
    with_fx :lpf, cutoff: :c3, amp: 1.0 do
      sample :bd_haus

      p get(:pick_scale)[0]
      at line(1, get(:bars)*4, steps:get(:bars)*4 - 1) do
        p get(:pick_scale).choose
      end
    end
  end
  sleep get(:bars)*4 - 1
end
