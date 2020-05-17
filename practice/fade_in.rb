# Fade in the baseline and full drum pattern over 4 iterations. Tweak FX
# parameters (LPF cutoff, level amp, etc) to do so.

use_bpm 40

live_loop :drums do
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

def base(n, sus)
  play n, attack: 0, release: 0, sustain: sus
  sleep sus
end

live_loop :baseline do
  sync :drums
  use_synth :fm

  with_fx :normaliser, level: 0.25 do
    with_fx :distortion, distort: 0.01 do
      at line(0, 8, steps: 8*4) do
        base :d3, 1.0/8
      end
    end
  end

  with_fx :nlpf, cutoff: :c3 do
    with_fx :distortion, distort: 0.2 do
      at [0, 2, 4], [:a3, :g3, :f3] do |n|
        base n, 1 + 3.0/4
        base :d3, 1.0/8
        base n, 1.0/8
      end
      sleep 6
      base :e3, 1.99
    end
  end
end

