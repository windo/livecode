set_sched_ahead_time! (0.5)
set_audio_latency! (-500)

live_loop :tock do
  4.times do
    cue :tick
    sleep 1.0
  end
end

def rchord(n, c, r)
  n = n - note(:c2)
  s = chord(n, c)
  r.times do |i|
    s += chord(n + i * 12, c)
  end
  return s
end

live_loop :do_sweeps do
  sync :tock
  def aplay(n, i, of)
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
  
  def sweeps(s, i, of, n)
    aplay s[i], i, of
    (n - 1).times do |p|
      d = (of.to_f / n) * (p + 1)
      aplay s[i - d], i - d, of
      aplay s[i + d], i + d, of
    end
  end
  
  def sweep(s)
    l = (s.length / 4).to_i * 4
    s.slice(0, l).each_index do |i|
      sweeps(s, i, l, 4)
      sleep (4.0 / l)
    end
  end
  
  with_synth :prophet do
    sweep(rchord(:a, :m, 6))
    sweep(rchord(:c, :M, 6))
    sweep(rchord(:g, :M, 6))
    sweep(rchord(:f, :M, 6))
  end
end

live_loop :drums do
  sync :tock
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
  live_audio :mic
end
