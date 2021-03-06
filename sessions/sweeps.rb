set_sched_ahead_time! (0.5)
set_audio_latency! (-500)

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

define :rchord do |n, c, r|
  n = n - note(:c2)
  s = chord(n, c)
  r.times do |i|
    s += chord(n + i * 12, c)
  end
  return s
end

live_loop :do_sweeps do
  sync_bpm :tock

  define :aplay do |n, i, of|
    m = of.to_f / 2
    if (i >= of) or (i < 0) then
      amp = 0.0
    elsif i < m then
      amp = (i.to_f / m.to_f) ** 1
    else
      amp = (1.0 - (i - m).to_f / m.to_f) ** 1
    end
    if amp > 0 then
      play n, amp: amp
    end
  end
  
  define :sweeps do |s, i, of, n|
    aplay s[i], i, of
    (n - 1).times do |p|
      d = (of.to_f / n) * (p + 1)
      aplay s[i - d], i - d, of
      aplay s[i + d], i + d, of
    end
  end
  
  define :sweep do |s, nosleep: false|
    l = (s.length / 4).to_i * 4
    s.to_a.slice(0, l).each_index do |i|
      sweeps(s, i, l, 4)
      sleep (4.0 / l) unless nosleep and i==l-1
    end
  end
  
  with_synth :prophet do
    sweep(rchord(:a, :m, 6))
    sweep(rchord(:c, :M, 6))
    sweep(rchord(:g, :M, 6))
    sweep(rchord(:f, :M, 6), nosleep: true)
  end
end

live_loop :drums do
  sync_bpm :tock
  in_thread do
    sample :bd_haus
    sleep 1.0
    sample :sn_dolf
    sleep 1.0
    sample :bd_haus
    sleep 0.75
    sample :bd_haus
    sleep 0.25
    sample :sn_dolf
    sleep 1.0
  end
  
  with_fx :reverb do
    in_thread do
      16.times do
        sample :drum_cymbal_open, sustain: 0.05, amp: 0.5
        sleep 0.25
      end
    end
  end
end

with_fx :octaver do
  live_audio :mic, :stop
end
