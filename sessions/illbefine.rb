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

live_loop :guitar do
  sync_bpm :tick
  tuner = nil

  with_fx :band_eq, freq: :a2, db: 20 do
    with_fx :autotuner do |fx|
      tuner = fx
      in_thread do
        16.times do
          live_audio_loop :justme4, 2, take: 1, beep: 1, amp: 4, onset: pick(2), nosleep: true
          sleep 0.5
        end
      end
    end
  end

  16.times do
    control tuner, note: (scale :a3, :minor_pentatonic, num_octaves: 1).choose
    sleep 0.5
  end
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
