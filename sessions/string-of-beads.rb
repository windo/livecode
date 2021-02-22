#set :scale, [:c4, :ionian]
set :scale, [:c4, :mixolydian]
#set :scale, [:c4, :dorian]
#set :scale, [:c4, :aeolian]

if not get(:init) then
  set :init, true

  set :reset_scale_tick, true
  set :scale_tick_advance, 0

  set :chord_amp, 0.7
  set :chord_chord_amp, 1.0
  set :chord_bass_amp, 1.5

  set :drone_amp, 1.0
  set :drone_reverb, 0.0
  set :drone_slide_one_in, 24
  set :drone_harmonics_one_in, 8

  set :percussion_amp, 1.0
  set :hh_amp, 0.5
  set :bd_amp, 2.0

  set :lala_amp, 1.0
  set :lala_sub_amp, 0.0
  set :lala_chord_amp, 1.0/3
  set :lala_dry_amp, 2.0

  set :solo, false
end

osc_set("/1/faderA", :chord_amp)
osc_set("/toggleA_1", :chord_bass_amp) { |v| v == 0 ? 0 : 1.5 }
osc_set("/1/faderB", :drone_amp)
osc_set("/1/rotaryB", :drone_reverb)
osc_set("/1/faderC", :percussion_amp)
osc_set("/1/faderD", :lala_amp) { |v| v * 2 }
osc_set("/toggleD_1", :reset_scale_tick) { |v| v == 0 ? false : true }
osc_set("/toggleD_2", :solo) { |v| v == 0 ? false : true }
on_osc("/encoderM") { set(:scale_tick_advance, get(:scale_tick_advance) + 1) }

=begin

Presence of mind, it winds
like strings of beads.
Blueberries on straws -
I eat them while they last.

One by one, they've gone, gone, gone.
Hear them dropping as they go.
An echo booms, all to lose,
.....

Hold my hand, hold my heart, hold my bones,
change my mind, shake my brain, save my soul.
Little sparks, they sparkle,
they pulse hidden in the flame.

She's gone, no she won't stay.
Dum, dum, dum, dum, dum, dum...

=end


live_loop :ticker do
  use_bpm 60

  if get(:reset_scale_tick) then
    tick_reset(:scale)
  end
  advance = get(:scale_tick_advance) || 0
  if advance > 0 then
    puts 'advancing by: ', advance
    advance.times { 16.times { tick(:scale) } }
    set(:scale_tick_advance, 0)
  end
  case (tick(:scale) / 16) % 4
  when 0
    set :scale, [:c4, :ionian]
  when 1
    set :scale, [:c4, :mixolydian]
  when 2
    set :scale, [:c4, :dorian]
  when 3
    set :scale, [:c4, :aeolian]
  end

  cue :beat
  t = tick(:beat)
  if t % 4 == 1 then
    cue :bar
  end
  sleep 1.0
end

define :mixer_channel do |amp: 1.0, solo: false, &block|
  if get(:solo) and not solo then
    amp = 0.0
  end
  with_fx :compressor, amp: amp do
    block.call
  end
end

define :pchord do |notes|
  s = scale(*get(:scale))
  puts('chord: ' + keyboard_keys(notes.map {|n| s[n]}))
  times, durations = [
    [[0], [1.125]],
    [[0, 0.75], [0.75, 0.625]],
    [[0, 1.0/3, 2.0/3], [1.0/3, 1.0/3, 1.0/3]],
  ].choose

  with_fx :level, amp: get(:chord_chrod_amp) do
    at times, durations do |duration|
      with_synth :saw do
        notes.each do |n|
          at [
            [0], [1.0/16],
          ].choose do
            3.times do
              play(
                s[n] - 0.05 + rand(0.1), pan: rand(1) - 0.5,
                attack: 0.05, release: duration,
                amp: 0.4,
              )
            end
          end
        end
      end
    end
  end

  with_fx :level, amp: get(:chord_bass_amp) do
    with_synth :subpulse do
      if one_in(6) then
        times = [0]
        durations = [1.0]
        lr = 1.0
      else
        lr = 0.5
      end
      at times, durations do |duration|
        play s[notes[0]] - 24, amp: 2.0, release: lr * duration
        play s[notes[0]] - 12 - 0.05 + rand(0.1), amp: 0.5, pan: -1, release: 0.9 * duration
        play s[notes[0]] - 12 - 0.05 + rand(0.1), amp: 0.5, pan: 1, release: 0.9 * duration
      end
    end
  end
end

live_loop :chords do
  sync :bar
  c = [
    [0, 2, 4],
    [4, 6, 8],
    [5, 7, 9],
    [3, 5, 7],
  ]

  mixer_channel solo: true, amp: get(:chord_amp) do
    at line(0, 4), c do |i, notes|
      if i != 0 then
        if one_in(2) then
          notes = notes + [(notes[0] + 6) % 7]
          if one_in(3) then
            notes = notes + [(notes[0] + 8) % 7]
          end
        end
      end
      notes = notes.map { |n| n % 7 }
      pchord notes
    end
  end

  sleep 3.9
end

define :pdrone do |n, to_n|
  [
    [0, 1.0, 0.5, true],
    [12, 1.0/4, 1.0, false],
    [24, 1.0/4, 0.25, true],
  ].each do |nd, amp, dur, slide|
    b = play(
      n + nd, note_slide: 0.1, amp: amp,
      pan: 1.0 - rand(2), pan_slide: 0.5,
      attack: 0.01, release: dur,
    )
    if slide then
      control b, note: to_n + nd, pan: 1.0 - rand(2)
    end
  end
end

live_loop :drone, init: 0 do |step|
  sync :bar
  s = scale(*get(:scale))
  
  bases = [
    [0, 0],
    [4, 0],
    [0, 1],
    [4, 1],
    [0, 2],
  ]
  ni, oct = bases[step]

  mixer_channel amp: get(:drone_amp) do
    with_fx :gverb, mix: get(:drone_reverb) do
      at line(0, 4, steps: 16) do |t, i|
        n = s[ni] + oct * 12
        if i == 15 and one_in(2) then
          drop = s[ni - 1] + oct * 12
          if drop > n then
            drop -= 12
          end
          pdrone drop, drop
        elsif one_in(get(:drone_slide_one_in)) then
          pdrone n + 1, n
        elsif one_in(get(:drone_slide_one_in)) then
          pdrone n, n - 1
        elsif one_in(get(:drone_harmonics_one_in)) then
          if s.to_a.include?(n + 3 % 12) then
            just_minor_third = hz_to_midi(midi_to_hz(n) * 6.0 / 5.0)
            pdrone n + 3, just_minor_third
          else 
            just_major_third = hz_to_midi(midi_to_hz(n) * 5.0 / 4.0)
            pdrone n + 4, just_major_third
          end
        elsif one_in(get(:drone_harmonics_one_in)) then
          just_fifth = hz_to_midi(midi_to_hz(n) * 3.0 / 2.0)
          pdrone n + 7, just_fifth
        else
          pdrone n, n
        end
      end
    end
  end

  sleep 3.9

  case
  when step == 0
    step = 1
  when step == bases.length - 1
    step -= 1
  when one_in(4)
    step = 0
  else
    step += rand_i(2) * 2 - 1
  end

  step
end

live_loop :percussion do
  sync :bar

  mixer_channel solo: false, amp: get(:percussion_amp) do
    # hihats
    steps = [4, 5, 6].choose
   hh = line(0, 1, steps: steps)
    long = []

    if one_in(2) then
      pos = steps - 1
      if one_in(2) then
        long = [hh[pos]]
      else
        pos -= rand_i(2) + 1
      end
      hh = hh.to_a
      hh.delete_at(pos)
    elsif one_in(2) then
      long = [0]
      hh = hh.to_a
      hh.delete_at(0)
    end

    with_fx :compressor, amp: get(:hh_amp) do
      at line(0, 4) do
        at hh do |i|
          t = i == 0 ? 2 : [0.5, 1, 1.5].choose
          sample(
            :drum_cymbal_closed,
            sustain: (4.0/steps/3) * t, release: 4.0/steps/3,
            amp: [1.0, 0.9].choose,
          )
        end
        at long do
          sample(
            :drum_cymbal_closed,
            rate: 0.9, sustain: 4.0/steps, release: 4.0/steps/3,
            amp: [1.0, 1.1].choose,
          )
        end
      end
    end

    # bass
    with_fx :compressor, amp: get(:bd_amp) do
      with_fx :lpf do
        sample :bd_boom, amp: 2.0
        synth :pulse, note: :c1
        synth :bnoise, release: 3.0, amp: 0.25
      end
      synth :pnoise, attack: 1.5, release: 2.0, amp: 0.1
    end
  end

  sleep 3.9
end

live_loop :lala do
  sync_bpm :beat
  mixer_channel solo: true, amp: get(:lala_amp) do
    s = scale(*get(:scale)) - 12
    puts "lala: #{get(:scale)[1]}: #{keyboard_keys(s)}"

    with_fx :lpf, amp: get(:lala_sub_amp), cutoff: s[0], res: 0.7 do
      with_fx :pitch_shift, pitch: -12 do
        live_audio :sub
      end
    end

   with_fx :level, amp: get(:lala_chord_amp) do
      with_fx :compressor do
        with_fx :autotuner, note: s[0] do
          with_fx :bpf, centre: s[0] do
            live_audio :root
          end
        end
        with_fx :autotuner, note: s[2] do
          with_fx :bpf, centre: s[2] do
            live_audio :third
          end
        end
        with_fx :autotuner, note: s[2] do
          with_fx :bpf, centre: s[2] do
            live_audio :fifth
          end
        end
        with_fx :autotuner, note: s[4] do
          with_fx :bpf, centre: s[4] do
            live_audio :seventh
          end
        end
      end
    end

    with_fx :level, amp: get(:lala_dry_amp) do
      live_audio :mic
    end
  end
  sleep 0.9
end
