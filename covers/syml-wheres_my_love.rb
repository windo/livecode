# SYML - Where's My Love

case :verse
when :verse
  strum =
      [[:a3, :m], [:c4, :M], [:f4, :M], [:d4, :m]] * 3 +
      [[:a3, :m], [:f4, :M], [:c4, :M], [:c4, :M]]
when :chorus
  strum =
      [[:g4, :M], [:e4, :m], [:f4, :M], [:f4, :M]] * 2 +
      [[:a3, :m], [:c4, :M], [:f4, :M], [:d4, :m]] * 2
end

def pchord(c)
  with_synth :hollow do
    play c[0]-24, sustain: 1.5, amp: 1.5, attack: 0.1
    amps = [1, 0.6, 0.8, 0.6, 0.8, 0.6].cycle
    6.times do
      play_chord chord(*c), sustain: 0.3, release: 0.1, amp: amps.next
      sleep 1.0/3
    end
  end
end

live_loop :tick do
  use_bpm 80
  sleep 1.0 + 1e-6
end

live_loop :drums do
  sync_bpm :tick
  sample :bd_boom, rate: 0.75, amp: 3.0
  sleep 2.0/3
  sample :drum_splash_soft, rate: 1.75, amp: 0.25
  sleep 2.0/3
  sample :drum_splash_soft, rate: 1.75, amp: 0.25
  sleep 2.0/3
end

live_loop :strum do
  sync_bpm :tick
  16.times do |i|
    pchord strum[i]
  end
end

def pluck(n)
  play n, amp: 0.25
  sleep 2.0/9
end

live_loop :melody do
  sync_bpm :tick
  with_synth :pluck do
    16.times do |i|
      [
        0, 2, 0,
        2, 1, 2,
        0, 2, 0,
      ].each do |n|
        pluck chord(*strum[i])[n]
      end
    end
  end
end
