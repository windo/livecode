live_loop :clicker do
  use_bpm 90
  if tick == 0 then
    sleep 0.1
  end
  trace_sync
  cue :line, [
    :gs4, :b4, :ds5,
    :gs4, :b4, :e5,
    :fs4, :b4, :ds5,
    :g4, :as4, :ds5,
  ]
  4.times do
    cue :bar
    4.times do
      cue :tick
      sleep 1.0
    end
  end
end

define :bd do |amp: 1.0|
  trace_drum :bd
  sample :bd_sone, amp: amp*0.5
  sample :drum_splash_soft, amp: amp*0.4, sustain: 0.1, release: 0.1
end

define :sn do
  trace_drum :sn
  sample :sn_zome
end

live_loop :drums do
  sync_bpm :bar
  at [0, 0.75, 1, 2, 2.75, 3] do
    bd
  end
  at [1.5, 3.5] do
    sn
  end
end

define :arp do |n, d|
  trace_note :arp, n, d 
  with_synth_defaults attack: 0.04, sustain: d, release: 0.08 do
    with_synth :saw do
      play n
    end
    with_synth :pulse do
      play n+12
    end
  end
end

ll :arp, 16, :line do |_, sync_value|
  l = sync_value[0]
  p = [0, 0, 1, 2]
  with_fx :compressor, threshold: 0.2 do
    with_fx :hpf, cutoff: :c5 do
      with_fx :reverb do
        at(line(0, 16), l.each_slice(3).to_a) do |bar|
          at line(0, 4) do
            at line(0, 1) do |_, i|
              if i == 0 then
                arp bar[p[i]], 0.1
              else
                arp bar[p[i]], 0.2
              end
            end
          end
        end
      end
    end
  end
end

define :bass do |n, d|
  trace_note :bass, n-24, d 
  with_fx :lpf, cutoff: :c6 do
    sample :bd_boom, amp: 0.4
    with_synth :subpulse do
      play n-24, sustain: d*0.9, release: d*0.1
    end
    with_synth :sine do
      play n, release: 0.5, amp: 0.3
    end
  end
end

ll :bass, 16, :line do |_, l|
  l = l[0]
  p = [0, 1, 2, 0, 2, 1]
  at(line(0, 16), l.each_slice(3).to_a) do |bar|
    at [0, 0.75, 1.5, 2.5, 3, 3.5] do |_, i|
      bass bar[p[i]], 1
    end
  end
end
