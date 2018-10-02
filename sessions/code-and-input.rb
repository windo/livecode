set_sched_ahead_time! (0.5)
set_audio_latency! (-500)

$bpm = 140

live_loop :metronome do
  use_bpm $bpm
  cue :tick
  sleep 1.0 + 1e-6
end

live_loop :drums do
  with_fx :bitcrusher do
    sync_bpm :tick
    in_thread do
      16.times do
        sample :drum_cymbal_soft
        sleep 1
      end
    end
    in_thread do
      sleep 15
      sleep 0.75
      sample :drum_cymbal_soft
    end
    3.times do
      sample :drum_heavy_kick, amp: 2.0
      sleep 2
      sample :sn_generic
      sleep 2
    end
    sample :drum_heavy_kick, amp: 2.0
    sleep 1
    sample :sn_generic
    sleep 2
    sample :sn_generic
    sleep 1
  end
end

with_fx :reverb do
  with_fx :echo do
    live_audio :mic, input: 1
  end
end

$s = scale(:c0, :dorian, num_octaves: 6)
$ni = 0

live_loop :midi_piano do
  note, velocity = sync "/midi/keystation_mini_32_midi_1/1/1/note_on"
  next if (velocity == 0)
  next if (!$s.include? note)
  $ni = $s.index note
end

live_loop :play_piano do
  sync_bpm :tick
  with_fx :slicer do
    with_synth :prophet do
      in_thread do
        play $s[$ni]
        sleep 0.5
        play $s[$ni+3]
        sleep 0.5
        play $s[$ni+6]
        sleep 0.5
        play $s[$ni]
        sleep 0.5
      end
    end
  end
end
