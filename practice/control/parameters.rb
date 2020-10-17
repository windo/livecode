# Control parameters to switch between tracks and effects.

live_loop :tock do
  use_bpm 180

  if tick(:tock) == 0 then
    sleep 1
    cue :tock
  end

  4.times do
    cue :tick
    sleep 1
  end
end

live_loop :drums, sync_bpm: :tock do
  with_fx :distortion, distort: 0.3, amp: 0.9 do
    at line(0, 8) + [6.5] do
      sample :bd_haus
    end
    at line(0, 8) + 1 + [3.75] do
      sample :sn_zome
    end
  end
  sleep 7
  sync_bpm :tock
end

live_loop :drum_run, sync_bpm: :tock do
  with_fx :level, amp: 0.9 do
    at line(0, 8, steps: 16) do |t, i|
      sample :sn_zome, rate: line(1.5, 0.5)[i/4]
    end
  end
  sleep 7
  sync_bpm :tock
end

live_loop :hihat_run, sync_bpm: :tock do
  with_fx :level, amp: 0.9 do
    at line(0, 8, steps: 32) do |t, i|
      sample :drum_cymbal_open, sustain: 0.05, amp: line(0, 1, steps: 32)[i]
    end
  end
  sleep 7
  sync_bpm :tock
end

live_loop :hihats, sync_bpm: :tock do
  with_fx :level, amp: 0.9 do
    at line(0, 8, steps: 16) do |t, i|
      sample :drum_cymbal_open, sustain: 0.05, amp: 0.3
    end
  end
  sleep 7
  sync_bpm :tock
end

live_loop :blade, sync_bpm: :tock do
  use_synth :blade
  with_fx :lpf, cutoff: :c5, amp: 0.9 do
    with_fx :slicer, phase: 0.5, pulse_width: 0.875 do
      with_fx :distortion, distort: 0.6, mix: 0.9 do
        at(
          line(0, 16, steps: 8),
          [:c2, :b1, :a1, :g1, :e2, :f2, :e2, :d2],
        ) do |n|
          play n, sustain: 2
          play n + 12, amp: 0.5, sustain: 1.5
        end
      end
    end
  end
  sleep 15
  sync_bpm :tock
end

live_loop :fm, sync_bpm: :tock do
  use_synth :fm
  with_fx :bitcrusher, rate: 20000, bits: 8, amp: 0.9 do
    [:c3, :a2, :e3, :d3].each_with_index do |n, i|
      at [0, 1] do
        play n
        play n+12, amp: 0.5
      end
      sleep 2.0 unless i==3
    end
  end
  sync_bpm :tock
end

live_loop :sine, sync_bpm: :tock do
  use_synth :sine
  with_fx :reverb, room: 0.7, amp: 0.9 do
    durations = (
      [1] * 6 + [2] +
      [1] * 4 + [2]
    )
    at(
      [
        0, 1, 2, 3, 4, 5, 5.5,
        8, 9, 10, 11, 11.5,
      ],
      [
        :e4, :e4, :f4, :f4, :e4, :e4, :d4,
        :c4, :g4, :a4, :a4, :g4,
      ],
    ) do |t, n, i|
        play n, release: durations[i]
        play n - 12, release: 0.25
        play n - 24, release: 0.5
        at line(0, 1) do
          play n + 12, release: 0.25, amp: 0.1
        end
      end
  end
  sleep 15
  sync_bpm :tock
end
