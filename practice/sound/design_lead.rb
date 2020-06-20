# Design a lead sound

define :lead do |n|
  with_synth :dsaw do
    play n
  end
end

# --- lead track below ---

live_loop :lead do
  sync_bpm :tock

  lick = [
    [:a5, :e5, :c5],
    [:g5, :e5, :c5],
    [:g5, :e5, :b4],
    [:g5, :d5, :b4],
  ]
  at line(0, 4*12, steps: 4), lick do |notes|
    at line(0, 12, steps: 12), ring(*notes) do |n|
      lead(n)
    end
  end
  sleep 4*12 - 0.1
end

live_loop :drum_track do
  sync_bpm :tock

  with_fx :reverb, room: 4.0 do
    with_fx :distortion, distort: 0.9 do
      with_fx :eq, low: 1, amp: 0.6 do
        sample :bd_haus
      end
    end
  end

  with_fx :compressor, pre_amp: 3.0, amp: 0.4 do
    with_fx :bitcrusher, mix: 0.6 do
      with_fx :lpf, cutoff: :c9 do
        at line(0, 12, steps: 12*2) do |t|
          sample :drum_cymbal_open, sustain: ring(0.05, 0.05, 0.15)[t], amp: 0.4
        end
      end
    end
  end

  sleep 12-0.1
end

live_loop :tock do
  use_bpm 160

  if tick == 0 then
    sleep 1.0
    cue :tock
  end

  4.times do
    cue :tick
    sleep 1.0
  end
end
