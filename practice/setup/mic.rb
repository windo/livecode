# Sing/jam along!

live_audio :mic

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
