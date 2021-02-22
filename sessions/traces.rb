live_loop :conductor do
  trace_sync current_bpm

  # Switch between scales
  if get(:scale) == nil or one_in(4) then
    set :scale, [[:c, :major], [:c, :minor], [:c, :mixolydian]].choose
  end
  trace_layer :scale, 4, get(:scale)

  cue :beat
  4.times do
    cue :tick
    sleep 1.0
  end
end

live_loop :blips do
  sync_bpm :tick
  # Random fast notes from the scale in a 5-rythm
  at line(0, 1, steps: 10) do
    n = (scale(*get(:scale), num_octaves: 3) - 12).choose
    trace_note :blip, n, 0.1
    play n, release: 0.1
  end
end

live_loop :chords do
  sync_bpm :tick
  # Play I, II and IV 7th chords (majors/minors according to scale)
  use_synth :dsaw
  notes = scale(*get(:scale), num_octaves: 2)
  at line(0, 1, steps: 4) do
    b = [0, 1, 3].choose
    c = [0, 2, 4, 6].map { |i| notes[b + i] }
    trace_notes :chord, c, 0.25
    play c, release: 0.25
  end
end

live_loop :bass do
  sync_bpm :beat
  # Play a single long bass note from scale, excluding B
  use_synth :fm
  n = scale(*get(:scale)).to_a.slice(0, 6).choose - 12
  trace_note :pad, n, 4.0
  play n, release: 4.0
  play n-12, release: 4.0
end

live_loop :slides do
  sync_bpm :beat
  # Occasionally slide over the whole scale over 4 octaves
  if one_in(4) then
    trace_layer :slides, 4
    notes = scale(*get(:scale), num_octaves: 4) - 12
    notes.each do |n|
      trace_note :slide, n, 0.05
      play n, amp: 0.1
      sleep 0.05
    end
  end
end

live_loop :drums do
  sync_bpm :beat
  if one_in(4) then
    # Slightly more intensive pattern
    trace_layer :drums, 4, :banging
    at line(0, 4, steps: 8) do
      trace_drum :bd
      sample :bd_haus
    end
    at line(0, 4, steps: 8) + 0.125 do
      trace_drum :sn
      sample :sn_zome
    end
    at line(0, 4, steps: 8) + 0.25 do
      trace_drum :hh
      sample :drum_cymbal_open
    end
  else
    # Relaxed pattern
    trace_layer :drums, 4
    at [0, 2] do
      trace_drum :bd
      sample :bd_haus
    end
    at [1, 3, 3.75] do
      trace_drum :sn
      sample :sn_zome
    end
    at line(0, 4, steps: 16) do
      trace_drum :hh, 1.0/16
      sample :drum_cymbal_open, sustain: 0.1
    end
  end
end
