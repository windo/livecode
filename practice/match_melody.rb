# Match the muffled melody in your own live loop.

set :bpm, 120
set :random_seed, RANDOM_SEED
with_random_seed get(:random_seed) do
  set :pick_scale, scale(
    :c4, [:major, :minor, :dorian, :phrygian, :lydian, :mixolydian].choose, num_octaves: 1)
end

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

live_loop :tock do
  use_bpm get(:bpm)
  8.times do
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
      at line(1, 8, steps:7 ) do
        p get(:pick_scale).choose
      end
    end
  end
end
