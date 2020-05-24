# Match the muffled melody in your own live loop.

$pick_scale = scale(:c4, :major, num_octaves: 1)
$bpm = 120
$random_seed = RANDOM_SEED

def p(n)
  with_synth :fm do
    play n
  end
end

live_loop :match do
  sync_bpm :tock

  # Match the meldoy here!
end

# --- random muffled melody below ---

live_loop :tock do
  use_bpm $bpm
  4.times do
    cue :tick
    sleep 1
  end
end

live_loop :melody do
  sync_bpm :tock
  with_random_seed $random_seed do
    with_fx :lpf, cutoff: :c3, amp: 1.0 do
      sample :bd_haus
      p $pick_scale[0]
      at line(1, 4, steps:3 ) do
        p $pick_scale.choose
      end
    end
  end
end
