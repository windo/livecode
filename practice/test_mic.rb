# Sing along!

def b(n)
  with_synth :fm do
    puts note_info(n)
    play n
    play note(n) - 12
    play note(n) + 12, amp: 0.25, release: 0.2
    sleep 0.5
  end
end

live_loop :base do
  s = scale(:c2, :major, num_octaves: 3)
  offset = ring(0, 0, 1, 3)[tick]
  [9, 9, 9, 9, 7, 7, 6, 5].each { |n| b(s[n + offset]) }
end

live_audio :mic
