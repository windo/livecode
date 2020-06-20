# Play along in real time.
#
# Limit yourself to real time notes and don't use MIDI inputs. All the sound
# functions work in real time by default. Turn off one of the amps to play that
# instrument.

set :bpm, 40
set :drum_amp, 1.0
set :bass_amp, 1.0
set :lead_amp, 1.0

# --- jam here ---

# sd
# bd
# hh
# bass :a
# lead :d

# --- sound functions below ---

define :bass do |n, sched_ahead: false, **kwargs|
  if not sched_ahead then
    use_real_time
  end
  with_synth :subpulse do
    play n-24, **kwargs
    play n-36, **kwargs
  end
end

define :lead do |n, sched_ahead: false, **kwargs|
  if not sched_ahead then
    use_real_time
  end
  with_synth :beep do
    play n-12, **kwargs
  end
end

define :bd do |sched_ahead: false|
  if not sched_ahead then
    use_real_time
  end
  sample :bd_haus
end

define :sd do |sched_ahead: false|
  if not sched_ahead then
    use_real_time
  end
  sample :sn_zome
end

define :hh do |sched_ahead: false|
  if not sched_ahead then
    use_real_time
  end
  sample :drum_cymbal_open, sustain: 0.1, amp: 0.4
end

# --- Play-along below

play_midi do |n|
  play n
end

live_loop :bass do
  sync_bpm :tock
  with_fx :level, amp: get(:bass_amp) do
    at(
      [0, 2, 4, 7, 7.5],
      [:g, :a, :d, :e, :f],
    ) do |_, n, i|
      release = case i
                when 0..1
                  2
                when 2
                  3
                when 3..4
                  0.5
                end
      bass n, release: release, sched_ahead: true
    end
  end
end

live_loop :lead do
  sync_bpm :tock
  with_fx :level, amp: get(:lead_amp) do
    at(
      [0, 0.25, 0.5, 1, 1.5, 1.75, 3.25, 3.5, 4.0, 4.5, 5.0, 5.5, 5.75],
      [:a, :a, :g, :f, :g, :e, :d, :e, :f, :e, :d, :e, :a-12],
    ) do |_, n, i|
      lead n, release: 0.5, sched_ahead: true
    end
  end
end

live_loop :drums do
  sync_bpm :tock

  with_fx :level, amp: get(:drum_amp) do
    at line(0, 8) do
      bd sched_ahead: true
    end
    at line(0, 8) + 1 do
      sd sched_ahead: true
    end
    at line(0, 8, steps: 16) do
      hh sched_ahead: true
    end
  end
end

live_loop :tock do
  use_bpm get(:bpm)
  if tick(:tock) == 0 then
    sleep 1.0
    cue :tock
  end
  8.times do
    cue :tick
    sleep 1.0
  end
end
