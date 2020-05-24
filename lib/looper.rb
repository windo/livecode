if not defined?($_live_audio_loop_takes) then
  $_live_audio_loop_takes = {}
end

# Record or play a sample from audio input
# Params:
# - name: name of the `buffer` to use
# - length: length (in beats) of the `buffer` to use
# - take: take number -> re-recorded if greater than the last recorded take
def live_audio_loop(name, length, take: 0, nosleep: false)
  key = [name, length]
  buf = buffer name, length
  if take == 0 then
    synth :sound_in, sustain: length
    sleep length unless nosleep
  elsif ($_live_audio_loop_takes[key] or 0) >= take then
    sample buf
    sleep length unless nosleep
  else
    $_live_audio_loop_takes[key] = take
    with_fx :record, buffer: buf do
      synth :sound_in, sustain: length
      sleep length unless nosleep
    end
  end
end
