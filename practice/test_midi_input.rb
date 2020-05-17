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

live_loop :midi_keyboard do
  device = ""
  n, velocity = sync "/midi/#{device}/note_on"
  next if (velocity == 0)
  play n
end
