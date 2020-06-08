# So sorry I couldn't say,
# How much I love you,
# I only have,
# This modest great ape brain.

$mic_amp = 0.0

$base_layer1 = true
$base_layer2 = true
$base_layer3 = true

$walks = 8
$walk_pause = false
$walk_roots = ring :b3, :a3
# $walk_roots = ring :b3, :e4, :c5
$walk_velocity = 80

if false then
  midi_all_notes_off
end

live_loop :bar do
  use_bpm 140

  if (tick :bar_start) == 0 then
    sleep 1
    cue :bar
  end

  8.times do
    cue :tock
    4.times do
      cue :tick
      sleep 1
    end
  end
end

def hh(sustain: 0.1)
  sample :drum_cymbal_soft, attack: 0.01, sustain: sustain
end

live_loop :drum do
  sync_bpm :tock
  with_fx :reverb do
    at [[0, 2], [0, 0.5, 2]].choose do
      sample :bd_haus
    end
    at [[1, 3], [1, 3, 3.5], [1, 3, 3.75]].choose do
      sample :sn_zome
    end
    with_fx :level, amp: 0.7 do
      at [0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5] do
        hh
      end
      case rand_i(3)
      when 0
        at [0.75, 1.25] do
          hh
        end
      when 1
        at [2.5, 3].pick(1) do
          hh(sustain: 0.4)
        end
      when 2
        # nothing
      end
    end
  end
end

def b(note, t, nosleep: false)
  layers = ($base_layer1 ? 1 : 0) + ($base_layer2 ? 1 : 0) + ($base_layer3 ? 1 : 0)
  case layers
  when 1
    velocity = 1.0
  when 2
    velocity = 0.8
  when 3
    velocity = 0.5
  end
  midi_note_on note, velocity
  in_thread do
    sleep t - 0.01
    midi_note_off note
  end
  sleep t unless nosleep
end

def play_lick(lick, keyboard: false)
  lick.each_with_index do |(n, d), i|
    keyboard([n]) if keyboard
    b n, d, nosleep: i==lick.length-1
  end
end

def keyboard_licks(licks)
  # 1. translate sleeps into timestamps
  by_ts = licks.map do |lick|
    lick.inject([[0]]) do |acc, (n, d)|
      this_ts = acc.last[0]
      next_ts = this_ts + d
      acc << [
        next_ts, [this_ts, n]
      ]
    end[1..-1].map { |acc, v| v }
  end
  # 2. group by timestamp, in-order
  grouped = Hash.new { |h, k| h[k] = [] }
  by_ts.each do |lick|
    lick.each do |ts, n|
      grouped[ts] << n
    end
  end
  # 3. at [timestamps], [notes] -> keyboard
  timestamps, notes = grouped.to_a.transpose
  at timestamps, notes do |notes|
    keyboard(notes)
  end
end


live_loop :base do
  sync_bpm :bar
  lick1 = [
    [:a3, 7],
    [:e3, 1],

    [:f3, 0.5],
    [:e3, 0.5],
    [:f3, 7],

    [:d3, 8],

    [:e3, 7],
    [:f3, 0.5],
    [:g3, 0.5],
  ]
  lick2 = [
    [:c4, 4],
    [:b3, 3.0/2],
    [:a3, 3.0/2],
    [:g3, 1],

    [:a3, 7],
    [:c4, 1],

    [:d4, 1],
    [:a3, 6],
    [:c4, 1],

    [:b3, 4],
    [:a3, 3.0/2],
    [:b3, 3.0/2 + 1],
  ]
  lick3 = [
    [:e4, 4],
    [:d4, 3.0/2],
    [:c4, 3.0/2],
    [:b3, 1],

    [:c4, 8],

    [:rest, 0.5],
    [:e4, 0.5],
    [:d4, 6],
  ] 
  if tick(:base_l3) % 2 == 0 then
    lick3 += [
      [:e4, 1],
      [:d4, 8],
    ]
  else
    lick3 += [
      [:d3, 1],
      [:b3, 8],
    ]
  end

  keyboard_licks([lick1, lick2, lick3])

  in_thread do
    with_midi_defaults port: "Midi Through Port-0", channel: 0 do
      play_lick(lick1, keyboard: false)
    end
  end if $base_layer1
  in_thread do
    with_midi_defaults port: "Midi Through Port-0", channel: 1 do
      play_lick(lick2, keyboard: false)
    end
  end if $base_layer2
  in_thread do
    with_midi_defaults port: "Midi Through Port-0", channel: 2 do
      play_lick(lick3)
    end
  end if $base_layer3

  sleep 31
end

def w(note, t, nosleep: false)
  with_midi_defaults port: "Midi Through Port-1", channel: 0 do
    midi_note_on note, $walk_velocity
    in_thread do
      sleep t - 0.1
      midi_note_off note
    end
    sleep t unless nosleep
  end
end

def ww(root, count, total: 4, nosleep: false, pulse: 0.5)
  total = total / pulse
  s = scale :a2, :minor, num_octaves: 4
  base_index = s.index(note(root))
  for c in 1..count
    w(s[base_index + (c-1)%3], pulse, nosleep: nosleep && (c == total))
  end
  if total > count && !nosleep then
    sleep (total - count) * pulse
  end
end

live_loop :walks do
  sync_bpm :bar
  next unless $walks > 0
  
  3.times do
    t = tick :walk_tick
    ww($walk_roots[t], $walks)
    if $walk_pause then
      sleep 4
    else
      ww($walk_roots[t], $walks)
    end
  end
  ww($walk_roots[0], $walks)
  if $walk_pause then
    # do nothing
  else
    ww($walk_roots[0], $walks, nosleep: true)
  end
end

with_fx :bitcrusher, rate:20000, bits:6, amp: $mic_amp do
  live_audio :mic
end
