$s = scale(:ab2, :minor, octaves: 2)

if false then
  set :synth_break, true
  set :chorus, false
end

live_loop :bar do
  use_bpm 75

  if tick(:bar) == 0 then
    sleep 1
    cue :bar
  end

  bar_length = 4
  if get :chorus then
    bar_length = 5
  end

  bar_length.times do
    cue :tock
    4.times do
      cue :tick
      sleep 1
    end
  end
end

define :play_base do |n, sustain: 0.0, **kwargs|
  with_synth :fm do
    play n, sustain: sustain-0.05, release: 0.05
    sleep 0.1+rand(0.1)
    play n, sustain: sustain-0.05, release: 0.05, amp: 0.25
  end
end

define :with_base_fx do |&block|
  with_fx :lpf, cutoff: :c4 do
    with_fx :distortion, mix: 0.2, mix_slide: 1.5 do |distortion|
      block.call distortion
    end
  end
end

live_loop :base do
  sync_bpm :bar

  with_base_fx do |distortion|
    if get :chorus then
      at [ 0, 4, 8, 12, 16, ], [ 4, 2, 2, 3, 0, ] do |t, n, i|
        at [0, 0.75, 2, 2.75] do |t, i|
          puts i
          sustain = 0.5
          if i % 2 == 1 then
            sustain = 1.25
          end
          play_base $s[n], sustain: sustain
        end
      end
      sleep 19.5
    else
      at [
        0,
        3, 4,
        7, 8,
        11, 12,
      ], [
        7,
        6, 5,
        4, 3,
        2, 0,
        ] do |t, n, i|
          nt = [0, 0.75, 2]
          sustain = [0.5, 1.25, 0.5]
          if i % 2 == 1 then
            nt = [0]
            sustain = [0.5]
          end
          if i == 6 then
            nt = [0, 0.75, 2, 2.75]
            sustain = [0.5, 1.25, 0.5, 1.25]
            control distortion, mix: 1.0, distort: 0.7
          end
          at nt, sustain do |sustain|
            play_base $s[n], sustain: sustain
          end
        end
        sleep 15.5
    end
  end
end


define :play_synth do |n, sustain: 0.0, **kwargs|
  sustain = sustain - 0.075
  with_synth :dsaw do
    play n, sustain: sustain, release: 0.125, **kwargs
  end
end

define :synth_break do
  set :synth_break, true
end

live_loop :synth do
  sync_bpm :bar
  if get(:synth_break) then
    set :synth_break, false
  else
    next
  end
  at(
    [0,
     3, 3.5, 4,
     7, 7.5, 8,
     11, 11.5, 12],
    [4,
     6, 7, 3,
     3, 4, 3,
     3, 2, 0]
  ) do |t, n, i|
    sustain = 3
    amp = 1.0
    if [1, 2].include?(i % 3) then
      sustain = 0.5
      amp = 1.2
    end
    if i == 9 then
      sustain = 4
    end
    play_synth $s[n], sustain: sustain, amp: amp
  end
  sleep 15.5
end


live_loop :mic do
  sync_bpm :bar
  if not get(:synth_break) then
    with_fx :chorus, delay: 0.1 do
      live_audio :mic, amp: 8.0
    end
  else
    live_audio :mic, :stop
  end
  sleep 15.5
end

live_loop :rythm do
  sync_bpm :tock

  at [0, 2] do
    at [0, 0.75, 1.25, 1.75]  do
      sample :bd_haus
    end

    at [0.5, 1.5] do
      sample :sn_zome
    end
  end
  
  sleep 3.5
end

