live_loop :tock do
  4.times do
    cue :tick
    sleep 1
  end
end

live_loop :guitar do
  sync_bpm :tock
  live_audio_loop :heartbeats, 16, take: 3, amp: 0.0
  with_fx :flanger do
    buf = buffer :heartbeats, 16
    sample buf
  end
  sleep 15
end

live_loop :beat do
  sync_bpm :tock
  at [0, 2] do
    sample :bd_haus
  end
  at [1, 3] do
    sample :sn_zome
  end
end
