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
  guitar = live_audio_loop :heartbeats, 16, take: 1, amp: 0
  play_cuts(guitar, 16, 32)

  live_audio_loop :lyrics, 16, take: 1

  with_fx :lpf, cutoff: :c5 do
    with_fx :pitch_shift, pitch: -24 do
      at line(0, 16) do
        live_audio_loop :clinks, 16, take: 1
      end
    end
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
