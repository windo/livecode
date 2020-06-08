# Match the muffled beat in your own live loop.

set :thirds, true
set :bpm, 120
set :random_seed, RANDOM_SEED

define :bd do
  sample :bd_haus
end

define :sn do
  sample :sn_zome
end

live_loop :match do
  # Match the beat here!

  sync_bpm :tock
end

# --- random muffled beat below ---

live_loop :tock do
  use_bpm get(:bpm)
  8.times do
    cue :tick
    sleep 1
  end
end

define :pick_beats do |offset|
  options = [
    [0],
    [0, 1],
    [0, 2],
    [0, 3],
    [0, 1, 2, 3],
  ]
  options.push(
    [0, 4.0/3],
    [0, 4.0/3*2],
    [0, 4.0/3, 4.0/3*2],
  ) if get(:thirds)
  return options.choose().map { |t| t+offset }
end

live_loop :beat do
  sync_bpm :tock
  with_random_seed get(:random_seed) do
    with_fx :lpf, cutoff: 50, amp: 1.0 do
      play :c5, release: 0.1
      with_bpm_mul 4 do
        line(0, 8, steps:8).each do |i|
          if i % 2 == 0 then
            at pick_beats(i * 4) do
              bd
            end
          else
            at pick_beats(i * 4) do
              sn
            end
          end
        end
      end
    end
  end
end
