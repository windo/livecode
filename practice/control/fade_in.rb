# Fade in and mix the bassline and full drum pattern.
#
# To do so, tweak the FX parameters:
#   * amp:
#   * level:
#   * cutoff:
#   * etc

live_loop :drums do
  use_bpm 40

  with_fx :reverb do
    with_fx :level, amp: 0.9 do
      at line(0, 1) do
        sample :drum_cymbal_open, sustain: 0.1, amp: 0.3
      end
      with_fx :level, amp: 0.0 do
        at 0 do
          sample :bd_haus, amp: 1.5
        end
        at 0.5 do
          sample :sn_zome, amp: 1.2
        end
      end
    end
  end
  sleep 1.0
end

define :bass do |n, d|
  with_synth :fm do
    play n, attack: 0, release: 0, sustain: d
  end
  sleep d
end

live_loop :bassline do
  sync_bpm :drums

  with_fx :normaliser, level: 0.5 do
    with_fx :distortion, distort: 0.1 do
      at line(0, 8, steps: 8*4) do
        bass :d3, 1.0/8
      end
    end
  end

  with_fx :nlpf, cutoff: :c2, amp: 0.0 do
    with_fx :distortion, distort: 0.1 do
      at [0, 2, 4], [:a3, :g3, :f3] do |n|
        bass n, 1 + 3.0/4
        bass :d3, 1.0/8
        bass n, 1.0/8
      end
      at [6] do
        bass :e3, 2
      end
    end
  end

  sleep 7
end

define :lead do |n|
  with_fx :slicer do
    play n
    play n - 12, release: 0.1, amp: 0.4
  end
  play n + 12, amp: 0.1
end

live_loop :lead do
  sync_bpm :bassline

  with_fx :reverb, amp: 0.0 do
    at(
      [
        0, 0.5, 0.75, 1, 1.5, 1.75, 2.25,
        3.5, 3.75, 4, 4.75, 5, 5.5, 5.75,
      ],
      [
        :d4, :e4, :d4, :c4, :b3, :d4, :a3,
        :g3, :a3, :b3, :c4, :b3, :a3, :b3,
      ],
    ) do |n|
        lead n
      end
  end
  sleep 7
end

play_midi do |n|
  play n
end
