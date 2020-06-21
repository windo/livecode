# Control parameters to fade and switch between tracks and effects.

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
  with_fx :level, amp: 1.0 do
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
  with_fx :level, amp: 1.0 do
    at line(0, 8, steps: 16) do |t, i|
      sample :sn_zome, rate: line(1.5, 0.5)[i/4]
    end
  end
  sleep 7
  sync_bpm :tock
end

live_loop :hihat_run, sync_bpm: :tock do
  with_fx :level, amp: 1.0 do
    at line(0, 8, steps: 32) do |t, i|
      sample :drum_cymbal_open, sustain: 0.05, amp: line(0, 1, steps: 32)[i]
    end
  end
  sleep 7
  sync_bpm :tock
end

live_loop :hihats, sync_bpm: :tock do
  with_fx :level, amp: 1.0 do
    at line(0, 8, steps: 16) do |t, i|
      sample :drum_cymbal_open, sustain: 0.05, amp: 0.3
    end
  end
  sleep 7
  sync_bpm :tock
end

live_loop :blade, sync_bpm: :tock do
  use_synth :blade
  with_fx :distortion, distort: 0.3, amp: 1.0 do
    play_pattern_timed(
      [:c2, :g2, :f2, :e2, :d2],
      [2, 2, 1.5, 1.5, 0.5],
    )
  end
  sync_bpm :tock
end

live_loop :fm, sync_bpm: :tock do
  use_synth :fm
  with_fx :bitcrusher, rate: 20000, bits: 8, amp: 1.0 do
    [:c3, :a2, :e3, :d3].each_with_index do |n, i|
      at [0, 1] do
        play (n)
      end
      sleep 2.0 unless i==3
    end
  end
  sync_bpm :tock
end
