# Sing/jam along!

define :b do |n, nosleep:false|
  with_synth :fm do
    puts note_info(n)
    play n
    play note(n) - 12
    play note(n) + 12, amp: 0.25, release: 0.2
    sleep 0.5 unless nosleep
  end
end

live_loop :bass do
  sync_bpm :drums

  s = scale(:c2, :major, num_octaves: 3)
  offset = ring(0, 0, 1, 3)[tick]
  [9, 9, 9, 9, 7, 7, 6, 5].each_with_index do |n, i|
    b(s[n + offset], nosleep:(i == 7))
  end
end

live_loop :drums do
  at [0] do
    sample :bd_haus
  end
  at [
    [0.5],
    [0.5, 0.875],
  ].tick do
    sample :sn_zome
  end
  sleep 1.0
end

live_audio :mic
