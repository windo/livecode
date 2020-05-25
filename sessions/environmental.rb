live_loop :tock do
  4.times do
    cue :tick
    sleep 1
  end
end

live_loop :environmental do
  sync_bpm :tock
  with_fx :reverb do
    live_audio_loop :trains, 4, take: 1, amp: 3.0
    live_audio_loop :traffic, 4, take: 3, amp: 10.0
  end
end

live_loop :clinks do
  sync_bpm :tock
  with_fx :echo, phase: 1.0, decay: 1.0 do
    live_audio_loop :clinks, 4, take: 2, amp: 1.0
    live_audio_loop :clanks, 4, take: 2, amp: 1.0
    live_audio_loop :keyboard, 4, take: 1, amp: 1.0
    live_audio_loop :knocks, 4, take: 1, amp: 1.0
  end 
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
