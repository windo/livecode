# Wrap the sound in effects.
#
# Go for clean, go for dirty, go for weird.

define :lead do |n, amp: 1.0, release: 1.0, **kwargs|
  amp *= 0.6
  with_synth :dsaw do
    play n, amp: amp, release: release, **kwargs
    play n+12, amp: 0.5*amp, attack: 0.1, release: 0.4, **kwargs
    play n+24, amp: 0.25*amp, attack: 0.1, release: 0.4, **kwargs
  end
end

live_loop :lead do
  sync_bpm :tock
  times = [
    0.0, 0.25, 0.75,
    3.5, 3.75, 4.0, 4.75, 5.5,
    8.0, 8.25, 8.75,
    11.0, 11 + 1.0/3, 11 + 2.0/3, 12.0,
  ]
  notes = [
    :e4, :b4, :b4,
    :a4, :g4, :a4, :b4, :g4,
    :e4, :a4, :a4,
    :a4, :g4, :fs4, :e4,
  ]
  d = 0.5
  durations = [
    d, d, 3,
    d, d, d, d, 2.5,
    d, d, 3,
    d, d, d, 4,
  ]
  at(times, notes) do |t, n, i|
    lead n, release: durations[i]
  end
  sleep 15
end

define :bass do |n, amp: 1.0, **kwargs|
  s = []
  with_synth :fm do
    s << play(n, amp: amp, **kwargs)
    s << play(n-12, amp: amp, **kwargs)
    s << play(n+12, amp: 0.5*amp, **kwargs)
  end
  s
end

live_loop :bass do
  sync_bpm :tock
  at(
    [
      0, 0.25,
      0.75, 1,
      1.5, 1.75,
      2.25, 2.5, 2.75,
      3.0, 3.5,
    ],
    [
      :e2, :g2,
      :e2, :a2,
      :e2, :b2,
      :e2, :g2, :a2,
      :c2, :d2,
    ],
  ) do |t, n, i|
      case i
      when 1, 3, 5, 9, 10
        bass n, release: 0.6
      else
        bass n, release: 0.4
      end
  end
end

live_loop :drums do
  sync_bpm :tock

  at line(0, 4) + [0.25, 1.75] do |t, i|
    sample :bd_haus, amp: t == 0 ? 1.5 : 1.0
  end

  at [0.75, 1.5, 2.75, 3.5] do
    sample :sn_zome
  end

  at line(0, 4, steps: 16) do |t, i|
    case i
    when 4, 12
      sample :drum_cymbal_open, sustain: 0.2, amp: 0.3
    else
      sample :drum_cymbal_open, sustain: 0.05, amp: 0.3
    end
  end

  if tick(:drums) % 4 == 0 then
    sample :drum_splash_soft
  end
end

live_loop :tock do
  if tick(:tock) == 0 then
    sleep 1.0
    cue :tock
  end
  4.times do
    cue :tick
    sleep 1.0
  end
end
