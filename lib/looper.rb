if not defined?($_live_audio_loop_takes) then
  $_live_audio_loop_takes = Hash.new { |h, k| h[k] = 0 }
end

# Preview, record, re-record and play buffers from audio input
#
# name, length - required to identify a buffer
# takes - 0 for audio preview, increase to record (and re-record)
# beep - amp level for recording beep
# amp - amp level for output
# ** - passed to playing the sample
def live_audio_loop(name, length, take: 0, beep: 0.0, amp: 1.0, **kwargs)
  key = [name, length]
  buf = buffer "#{name}_#{take}", length

  case
  # Asking for a new take!
  when take > $_live_audio_loop_takes[key]
    # Possibly beep to indicate recording 
    with_synth :beep do
      play :c6, release: 0.1, amp: beep
    end

    # Record!
    $_live_audio_loop_takes[key] = take
    cue "_record_#{name}"
    with_fx :record, buffer: buf do
      synth :sound_in, sustain: length, amp: amp
    end

  # Preview mode
  when take == 0
    with_synth :beep do
      play :c6, release: 0.1, amp: beep
    end

    synth :sound_in, sustain: length, amp: amp

  else
    # The take exists - play it!
    sample buf, amp: amp, **kwargs
  end

  return buf
end
