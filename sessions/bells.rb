live_loop :bar do
  use_bpm 140

  if tick(:first_bar) == 0 then
    sleep 1
    cue :bar
  end

  4.times do
    cue :tock
    4.times do
      cue :tick
      sleep 1
    end
  end
end

live_loop :beat do
  sync_bpm :tock

  at [0, 1, 2, 3] do
    sample :bd_pure
  end

  at [2] do
    sample :sn_zome
  end
end

live_loop :walks do
  sync_bpm :tock
  r = scale(:c, :chromatic).choose
  c = chord(r, [:major, :minor].choose)

  in_thread do
    with_fx :reverb do
      with_synth :fm do
        3.times do |i|
          3.times do |j|
            play c[j] + i*12 - 12
            sleep 1.0/3
          end
        end
        play c[0] + 2*12
      end
    end
  end

  with_synth :mod_fm do
    play c[0] - 24, release: 3.0, amp: 0.5
  end
end
