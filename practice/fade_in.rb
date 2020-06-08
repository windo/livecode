# Fade in the baseline and full drum pattern. Tweak FX parameters (LPF cutoff,
# level amp, etc) to do so.

live_loop :drums do
  use_bpm 40

  with_fx :reverb do
    with_fx :level, amp: 0.5 do
      at line(0, 1) do
        sample :drum_cymbal_open, sustain: 0.1, amp: 0.3
      end
      with_fx :level, amp: 0 do
        at 0 do
          sample :bd_haus, amp: 1.0
        end
        at 0.5 do
          sample :sn_zome, amp: 1.0
        end
      end
    end
  end
  sleep 1.0
end

define :bass do |n, d|
  play n, attack: 0, release: 0, sustain: d
  sleep d
end

live_loop :bassline do
  sync_bpm :drums
  use_synth :fm

  with_fx :normaliser, level: 0.25 do
    with_fx :distortion, distort: 0.01 do
      at line(0, 8, steps: 8*4) do
        bass :d3, 1.0/8
      end
    end
  end

  with_fx :nlpf, cutoff: :c3 do
    with_fx :distortion, distort: 0.2 do
      at [0, 2, 4], [:a3, :g3, :f3] do |n|
        bass n, 1 + 3.0/4
        bass :d3, 1.0/8
        bass n, 1.0/8
      end
      sleep 6
      bass :e3, 1.99
    end
  end
end

