live_loop :tock do
  if tick(:tock) == 0 then
    sleep 1
    cue :tock
  end

  4.times do
    cue :tick
    sleep 1
  end
end

def play_cuts(buf, d, cuts)
  in_thread do
    (0...cuts).to_a.shuffle.each do |cut|
      s = cut.to_f / cuts
      sample buf, start: s, finish: s+1.0/cuts
      sleep d.to_f / cuts
    end
  end
end

live_loop :guitar do
  sync_bpm :tock
  live_audio_loop :heartbeats, 16, take: 0, beep: 1, amp: 4, nosleep: true
  # play_cuts(guitar, 16, 32)

  sleep 15
end

live_loop :lyrics do
  sync_bpm :guitar
  live_audio_loop :lyrics, 16, take: 0, nosleep: true, amp: 1.0

  sleep 15
end

live_loop :beat do
  sync_bpm :tock
  at [0, 2, 2.5] do
    sample :bd_haus
  end
  at [1, 1.75, 3] do
    sample :sn_zome
  end
end

live_loop :vj do
  sync_bpm :tock
  vj_bpm
  vj_track if one_in(1)
  vj_seek 0
end
