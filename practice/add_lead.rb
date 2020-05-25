# Add a lead for the baseline.

$random_seed = RANDOM_SEED
$bpm = 60

live_loop :leads do
  sync_bpm :tock
end


# --- stock base below ---

live_loop :tock do
  use_bpm $bpm
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

def b(n, t)
  play n, sustain: t * 0.75, attack: 1.0/16, release: 1.0/16
  play n + rand(0.1), sustain: t * 0.75, attack: 1.0/16, release: 1.0/16, amp: 0.5
  play n - 12, sustain: t, attack: 1.0/16, release: 1.0/16, amp: 0.5
  play n + 12, release: t, attack: 1.0/16, amp: 0.1
  sleep t
end

live_loop :baseline do
  sync_bpm :tock
  use_synth :fm

  times = [2.0/3, 1.0/6, 1.0/6] * 4

  lick = with_random_seed $random_seed do
    root = scale(:c2, :chromatic).choose
    notes = scale(root, [:major, :minor].choose)

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
