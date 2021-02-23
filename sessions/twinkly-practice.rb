# Add a lead track for the baseline.

set :random_seed, 78
set :bpm, 60

define :lead do |n|
  trace_note :lead, n, 0.25
  with_synth :pulse do
    play n - 12, release: 0.25
  end
  with_synth :saw do
    play n, amp: 0.5, release: 0.125
  end
end

live_loop :leads, sync: :tock do

  # ting-ting-ting-ting...
  at(
    [
      0.5, 0.75, 1, 1.25,
      2.5, 2.75, 3.0, 3.25, 3.5
    ],
    [
      :f4, :f4, :f4, :ds4,
      :fs4, :fs4, :fs4, :f4, :ds4,
    ]
  ) do |n|
    lead n
  end

  # dum-dah, du-dam-dah-da...
  at(
    [
      0.0, 0.5,
      2.5, 2.75, 3.25, 3.75,
    ],
    [
      :cs4, :gs4,
      :gs4, :cs5, :c5, :as4,
    ]
  ) do |n|
    lead n
  end

  # lick
  at(
    [
      0.0, 0.125,
      0.5, 0.75, 1.0, 1.25,
      1.75, 2.25, 2.75, 3.25, 3.75, 4.0,
    ],
    [
      :e6, :f6,
      :fs6, :e6, :f6, :cs6,
      :ds6, :b5, :c6, :as5, :f5, :gs5,
    ]
  ) do |n|
    lead n
  end

  sync :tock
end

play_midi do |n|
  lead n
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
  with_synth :fm do
    play n, sustain: t * 0.75, attack: 1.0/16, release: 1.0/16
    play n + rand(0.1), sustain: t * 0.75, attack: 1.0/16, release: 1.0/16, amp: 0.5
    play n - 12, sustain: t, attack: 1.0/16, release: 1.0/16, amp: 0.5
    play n + 12, release: t, attack: 1.0/16, amp: 0.1
  end
  sleep t
end

live_loop :baseline do
  sync_bpm :tock

  times = [2.0/3, 1.0/6, 1.0/6] * 4

  lick = with_random_seed get(:random_seed) do
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
