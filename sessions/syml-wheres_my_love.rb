# SYML - Where's My Love
#
# ...
#
# Cold sheets
# But where's my love
# I am searching high
# I'm searching low in the night
#
# Oooh, does she know that we bleed the same?
# Oooh, don't wanna cry, but I break that way
#
# Did she run away? Did she run away? I don't know
# If she ran away, If she ran away, come back home
# Just come home
#
# ...

case :chorus
when :verse
  set(
    :strum,
    [[:a3, :m], [:c4, :M], [:f4, :M], [:d4, :m]] * 3 +
    [[:a3, :m], [:f4, :M], [:c4, :M], [:c4, :M]]
  )
when :chorus
  set(
    :strum,
    [[:g4, :M], [:e4, :m], [:f4, :M], [:f4, :M]] * 2 +
    [[:a3, :m], [:c4, :M], [:f4, :M], [:d4, :m]] * 2
  )
end

define :pchord do |r, c|
  with_fx :reverb, room: 2 do
    with_fx :lpf, cutoff: :c5, amp: 0.7 do
      with_synth :pulse do
        play r-24, sustain: 1.9, amp: 0.7, attack: 0.1
        amps = [1, 0.6, 0.8, 0.6, 0.8, 0.6].cycle
        6.times do
          play_chord chord(r, c)+rand()*0.2, sustain: 0.3, release: 0.1, amp: amps.next
          sleep 1.0/3
        end
      end
    end
  end
end

live_loop :tick do
  use_bpm 100
  sleep 1.0 + 1e-6
end

live_loop :drums do
  sync_bpm :tick
  with_fx :reverb, room: 1 do
    with_fx :distortion, distort: 0.4, amp: 2.0 do
      sample :bd_boom, rate: 0.75
    end
    sleep 2.0/3
    sample :drum_splash_soft, rate: 1.75, amp: 0.25
    sleep 2.0/3
    sample :drum_splash_soft, rate: 1.75, amp: 0.25
    sleep 2.0/3
  end
end

live_loop :strum do
  sync_bpm :tick
  16.times do |i|
    r, c = get(:strum)[i]
    keyboard [r]
    pchord(r, c)
  end
end

define :pluck do |n|
  play n, amp: 1.0
  play n - 24, amp: 0.5
  play n - 36, amp: 0.25
  sleep 2.0/9
end

live_loop :melody do
  sync_bpm :tick
  with_synth :pluck do
    16.times do |i|
      (r, c) = get(:strum)[i]
      puts i, r, c
      puts get(:strum)
      notes = chord(r, c)
      [
        0, 2, 0,
        2, 1, 2,
        0, 2, 0,
      ].each do |n|
        pluck notes[n]
      end
    end
  end
end

