set_sched_ahead_time! (0.0)
set_audio_latency! (-500)

# So sorry I couldn't say
# how much I love you
# I only have
# this modest great ape brain
$mic_amp = 3.0

$base_layer1 = true
$base_layer2 = true
$base_layer3 = true

$walks = 6
$walk_pause = true
# $walk_roots = ring :b3, :a3
$walk_roots = ring :b3, :e4, :c5
$walk_velocity = 60

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
      with_swing rand(0.1) do
        at [0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5] do
          hh
        end
        case rand_i(3)
        when 0
          at [0.75, 1.25] do
            hh
          end
        when 1
          at [2.5] do
            hh(sustain: 0.5)
          end
        when 2
          # nothing
        end
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

live_loop :base do
  sync_bpm :bar
  in_thread do
    with_midi_defaults port: "Midi Through Port-0", channel: 0 do
      b :a3, 7
      b :e3, 1
      
      b :f3, 0.5
      b :e3, 0.5
      b :f3, 7
      
      b :d3, 8
      
      b :e3, 7
      b :f3, 0.5
      b :g3, 0.5, nosleep: true
    end
  end if $base_layer1
  in_thread do
    with_midi_defaults port: "Midi Through Port-0", channel: 1 do
      b :c4, 4
      b :b3, 3.0/2
      b :a3, 3.0/2
      b :g3, 1
      
      b :a3, 7
      b :c4, 1
      
      b :d4, 1
      b :a3, 6
      b :c4, 1
      
      b :b3, 4
      b :a3, 3.0/2
      b :b3, 3.0/2 + 1, nosleep: true
    end
  end if $base_layer2
  in_thread do
    with_midi_defaults port: "Midi Through Port-0", channel: 2 do
      with_swing rand(0.1) do
        b :e4, 4
        b :d4, 3.0/2
        b :c4, 3.0/2
        b :b3, 1
        
        b :c4, 8
        
        sleep 0.5
        b :e4, 0.5
        b :d4, 6
        
        if rand_i(2) == 0 then
          b :e4, 1
          # last bar
          b :d4, 8, nosleep: true
        else
          b :d3, 1
          # last bar
          b :b3, 8, nosleep: true
        end
      end
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

def ww(root, count, total: 8, nosleep: false, pulse: 0.5)
  puts root, count
  s = scale :a2, :minor, num_octaves: 3
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
  #with_fx :autotuner do
  live_audio :mic
  #end
end
