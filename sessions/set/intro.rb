set :walk_pattern, ring(3, -7, 4, 2)
set :walk_resets, ring(0, 1, 2, 0, 3)
set :chord_ring, ring(
  [:c3, :M],
  [:c3, :M],
  [:f3, :m7],
  [:f3, :m7],
  [:c3, :m],
  [:c3, :m],
  [:g3, :madd9],
  [:g3, :madd9],
)

live_loop :bar do
  if tick(:bar) == 0 then
    sleep 1
    cue :bar
  end
  trace_sync
  4.times do
    cue :tock
    cue :chord, get(:chord_ring)[tick(:chord)]
    8.times do
      cue :tick
      sleep 0.125
    end
  end
end

define :beat_fx do |&block|
  with_fx :level, amp: 0.2 do
    block.call
  end
end

live_loop :beat do
  sync_bpm :bar
  beat_fx do
    bds = 8
    at line(0, 4, steps: bds) do |i|
      amp = 2.0
      if i == 0 then
        amp = 3.0
      end
      trace_drum :bd
      sample :bd_haus, sustain: 4.0/bds/2, release: 4.0/bds/2, amp: amp
    end
    offset1, offset2 = ring([0.25, 0.75], [0.5, 0.625])[tick(:sn)]
    at (line(0, 4) + offset1) + (line(0, 4) + offset2) do
      trace_drum :sn
      sample :sn_zome, amp: 2.0, sustain: 4.0/16
    end
    hhs = ring(8 * 3, 32, 4 * 5, 32)[tick(:hh)]
    with_fx :hpf, amp: 1.5 do
      at line(0, 4, steps: hhs) do
        trace_drum :hh
        sample :drum_cymbal_closed, start: 0.05, sustain: 4.0/hhs/2
      end
    end
  end

  sleep 3.5
end

define :bass_fx do |&block|
  with_fx :level, amp: 0.05 do
    with_fx :eq, low_shelf: 0.7, low: 1.2, mid: 0.6, high: -0.9, high_shelf: -1.0 do
      with_fx :distortion, mix: 0.1, mix_slide: 1.0, distort: 0.5 do |distortion|
        block.call distortion
      end
    end
  end
end

define :bass do |n, low_amp: 1.0|
  synth :fm, note: n, attack: 0.2, sustain: 0.25, release: 0.2, amp: 0.4
  synth :fm, note: n - 12, attack: 0.01, sustain: 0.2, release: 0.3, amp: 1.0
  trace_note :bass, n
  3.times do
    synth :pulse, note: n - 24 + rand(0.02), attack: 0.01, sustain: 0.3, release: 0.7, amp: 0.1 * low_amp
  end
end

live_loop :bass do
  root, cname = sync_bpm :chord

  cnotes = chord(root, cname, num_octaves: 2).sort
  keyboard chord(root, cname)
  nonroot = ring(*cnotes.to_a.slice(1, 99))
  notes = [cnotes[0]] + nonroot.shuffle.to_a.slice(0, 3).sort

  bass_fx do |distortion|
    control distortion, mix: 0.3
    at line(0, 1), notes do |i, n|
      amp = 1
      if i == 0 then
        amp = 1.5
      end
      bass n, low_amp: amp
    end
  end
end

define :walk_fx do |&block|
  with_fx :level, amp: 0.1 do
    with_fx :eq, low_shelf: -1.0, low: -0.5 do
      with_fx :gverb, mix: 0.2 do
        block.call
      end
    end
  end
end

define :walk do |n|
  trace_note :walk, n, 0.2
  synth :dsaw, note: n, sustain: 0.1, release: 0.1
  in_thread do
    3.times do
      synth :pulse, note: n+rand(0.1), sustain: 0.1, release: 0.1, pan: [-1, 1].choose
      sleep 1.0/8/3
    end
  end
end

live_loop :walks, init: 0 do |i|
  root, cname = sync_bpm :chord
  walk_fx do
    8.times do
      sync_bpm :tick
      cnotes = chord(root, cname, num_octaves: 5).sort
      clen = chord(root, cname).length

      t = tick
      i += get(:walk_pattern)[t]
      if t % 12 == 0 then
        i = get(:walk_resets)[(t/12).round] * clen
      end
      if i < 0 then
        i = 0
      end
      if i >= cnotes.length then
        i -= 4
      end

      n = cnotes[i]
      walk n
    end
  end

  i
end
