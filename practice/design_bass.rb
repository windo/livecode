# Design a bass sound

define :bass do |n, d|
  with_synth :subpulse do
    play n, sustain: d, release: 0.1, note_slide: 0.1
  end
end

# --- sample base track below ---

live_loop :bass_track do
  sync_bpm :bar
  last = nil
  at (line(0, 16, steps: 16) + [7.5, 15.5]).sort, [
    [:a2, 0.2],
    [:a2, 0.2],
    [:a2, 0.2],
    [:e2, 0.8],

    [:f2, 0.2],
    [:f2, 0.2],
    [:f2, 0.2],
    [:f2, 0.8],
    [:e2, -1],

    [:d2, 0.2],
    [:d2, 0.2],
    [:d2, 0.2],
    [:f2, 0.8],

    [:e2, 0.2],
    [:e2, 0.2],
    [:e2, 0.2],
    [:g2, 0.8],
    [:gs2, -1],
  ] do |i, (n, d)|
    if d == -1 then
      control last, note: n
    else
      last = bass n, d
    end
  end
end

live_loop :drum_track do
  sync_bpm :tock

  with_fx :compressor, pre_amp: 3.0, amp: 0.7 do
    at [0, 2] do
      sample :bd_haus
    end
    at [1, 3] do
      sample :sn_zome
    end
  end
end

live_loop :bar do
  use_bpm 90

  if tick == 0 then
    sleep 1.0
    cue :bar
  end

  4.times do
    cue :tock
    4.times do
      cue :tick
      sleep 1.0
    end
  end
end
