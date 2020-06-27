# Play along!

live_loop :beat do
  use_bpm 90
  at [0, 2] do
    sample :bd_haus
  end
  at [1, 3] do
    sample :sn_zome
  end
  sleep 4
end

live_loop :midi_keyboard, init: nil do |last|
  if last.nil? then
    last = {}
  end

  with_real_time do
    n, velocity = sync "/midi:*/note_on"
    if velocity == 0 then
      if not last[n].nil? then
        control last[n], amp: 0
        last.delete(n)
      end
    else
      last[n] = synth :fm, note: n, amp: velocity.to_f / 127, amp_slide: 0.1
    end
  end

  last
end
