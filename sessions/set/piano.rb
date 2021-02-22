live_loop :conductor do
  use_bpm 80

  if tick == 0 then
    sleep 0.1
  end

  bar = tick(:bar)

  chords = ring(
    [:c3, :M7],
    [:f3, :M7],
    [:c3, :m7],
    [:g3, :m7],
  )

  scales = ring(
    [:c3, :major],
    [:c3, :minor],
  )

  set(:scale, scales[bar/2])
  in_thread do
    trace_highlight scale(*get(:scale), num_octaves: 4)-12
  end
  set(:chord, get(:next_chord) || chords[bar])
  set(:next_chord, chords[bar + 1])
  in_thread do
    sleep 3
    chord(*get(:next_chord)).each do |n|
      trace_note :next_chord, n
    end
  end

  trace_sync current_bpm
  cue :bar, bar%4
  4.times do |i|
    cue :beat, i
    sleep 1
  end
end

play_midi("keystation_*") do |n, vel_f: 1.0, **kwargs|
  trace_note :keyboard, n, 0.0
  midi_note_on n, port: "midi_through_midi_through_port-1_14_1", channel: 0, vel_f: vel_f**0.5, **kwargs
  -> { 
    midi_note_off n, port: "midi_through_midi_through_port-1_14_1", channel: 0
    trace_note_off :keyboard, n
  }
end

define :piano do |n, sustain: 1.0, **kwargs|
  n = [n] unless n.kind_of? ring.class
  n.each do |n|
    trace_note :piano, n, sustain
    midi n, port: "midi_through_midi_through_port-0_14_0", channel: 0, sustain: sustain, **kwargs
  end
end

ll :chords, 4, :bar do
  at [0, 2] do
    at(
      [0, 0.25, 0.75, 1.25],
      [0.20, 0.20, 0.20, 0.5],
    ) do |d|
      piano chord(*get(:chord)), vel_f: 0.75, sustain: d
    end
  end
end

ll :bassline, 4, :bar do |bar|
  measure = (
    case bar
    when 0
      [[0, 3], [[:g2, 3], [:c2, 1]]]
    when 1
      [[0], [[:f2, 4]]]
    when 2
      [[0, 3], [[:ds2, 3], [:f2, 1]]]
    when 3
      [[0], [[:as1, 4]]]
    end
  )
  at(*measure) do |(n, d)|
    piano n, vel_f: 0.75, sustain: d
  end
end

ll :percussion, 4, :bar do |bar|
  with_fx :eq, low_shelf: 0.4, low: 0.5 do
    at [0] do
      trace_drum :bd_bar
      sample :bd_haus, amp: 0.5
    end
    at ring(
      [0, 0.75, 2],
      [0, 0.75, 2.5],
      [0, 2.5],
      [0, 0.75, 1.5],
    )[bar] do
      trace_drum :bd
      sample :bd_boom
    end
  end
  at line(0, 4, steps: 16) do |_, i|
    d = (
      case i
      when 5, 11, 14
        0.1
      else
        0.05
      end
    )
    trace_drum :hh, d
    with_fx :lpf, cutoff: :c9 do
      with_fx :hpf do
        with_fx :reverb do
          sample :drum_cymbal_open, sustain: d*0.8, release: d*0.2, amp: 0.6
        end
      end
    end
  end
end
