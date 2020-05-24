# Match the muffled beat in your own live loop.

$thirds = true
$swing = false
$bpm = 120
$random_seed = RANDOM_SEED

def bd()
  sample :bd_haus
end

def sn()
  sample :sn_zome
end

live_loop :match do
  sync_bpm :tock

  # Match the beat here!
end

# --- random muffled beat below ---

live_loop :tock do
  use_bpm 120
  4.times do
    cue :tick
    sleep 1
  end
end

def pick_beats(offset)
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
  ) if $thirds
  return options.choose().map { |t| t+offset }
end

live_loop :beat do
  sync_bpm :tock
  with_random_seed $random_seed do
    with_fx :lpf, cutoff: 50, amp: 1.0 do
      play :c5, release: 0.1
      with_swing rand(0.1) do
        with_bpm_mul 4 do
          at pick_beats(0) do
            bd
          end
          at pick_beats(4) do
            sn
          end
          at pick_beats(8) do
            bd
          end
          at pick_beats(12) do
            sn
          end
        end
      end
    end
  end
end
