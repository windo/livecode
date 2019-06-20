set_sched_ahead_time! (0.5)
set_audio_latency! (-500)

live_loop :tock do
  4.times do
    cue :tick
    sleep 1
  end
end

live_loop :drums do
  sync :tock
  sample :bd_haus
  sleep 1
  sample :sn_dolf
  sleep 1
  sample :bd_haus
  sleep 0.75
  sample :bd_haus
  sleep 0.25
  sample :sn_dolf
end

if not defined?($takes) then
  $takes = {}
end

# Record or play a sample from audio input
# Params:
# - n: name of the `buffer` to use
# - l: length (in beats) of the `buffer` to use
# - t: take number -> re-recorded if greater than the last recorded take
def llr(n, l, t)
  k = [n, l]
  b = buffer n, l
  if t == 0 then
    synth :sound_in, sustain: l
    sleep l
  elsif ($takes[k] or 0) >= t then
    sample b
    sleep l
  else
    $takes[k] = t
    with_fx :record, buffer: b do
      synth :sound_in, sustain: l
      sleep l
    end
  end
end

live_loop :baseline do
  sync :tock
  with_fx :octaver do
    llr :baseline, 4, 4
  end
end

