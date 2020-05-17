# Fade the synth from blade to fm track.

live_loop :drums do
  4.times do
    use_bpm 180
    sample :bd_haus
    sleep 1.0
    sample :sn_zome
    sleep 1.0
  end
end


live_loop :blade do
  sync_bpm :drums
  use_synth :blade
  with_fx :distortion, distort: 0.3, amp: 1.0 do
    play_pattern_timed [:c2, :g2, :f2, :e2, :d2], [2, 2, 1.5, 1.5, 0.5]
  end
end

live_loop :fm do
  sync_bpm :drums
  use_synth :fm
  with_fx :bitcrusher, rate: 20000, bits: 8, amp: 0.0 do
    [:c3, :a2, :e3, :d3].each_with_index do |n, i|
      at [0, 1] do
        play (n)
      end
      sleep 2.0 unless i==3
    end
  end
end
