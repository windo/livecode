live_loop :metronome do
  use_bpm 50
  cue :tick
  sleep 1.0
  sleep 1e-3
end

$cmap = {
  :am => [:a3, :m],
  :c => [:c4, :M],
  :g => [:g3, :M],
  :em => [:e4, :m],
}

# amp
$drum_amp = 1.0
# One of: :chorus, :verse
$part = :verse
# One of: :slow, :fast, :chord
$pstyle = :chord

# signalling
$first_bar = true
$last_bar = false

def pchord(c)
  c = chord(*$cmap[c])
  case $pstyle
  when :slow
    pattern = [0, 1, 2, 0].map{ |i| c[i] }
  when :fast
    pattern = [
      0, 1, 2, 0,
      2, 1, 0, 1,
    ].map{ |i| c[i] }
    pattern[6] += 12
    pattern[2] += 12 
  when :chord
    2.times do 
      play c[0] - 12
      play_chord c, amp: 3
      sleep 1.0/6
      play_chord c, amp: 2.5
      sleep 1.0/6
      play c[0], amp: 1
      sleep 1.0/6
    end
    return
  end
  play_pattern_timed pattern, 1.0 / pattern.length, amp: 1.5
end

def pp(line)
  line.each_index do |i|
    cname = line[i]
    if i == 0 || line[i - 1] != cname then
      base = chord(*$cmap[cname])[0] - 12
      with_fx :distortion do
        play base - 12, sustain: line.length, amp: 0.5
      end
    end
    $last_bar = i == line.length - 1
    $first_bar = i == 0
    cue :pp_bar
    pchord line[i]
    $last_bar = false
    $first_bar = false
  end
end

live_loop :chords do
  use_synth :pluck
  sync_bpm :tick
  case $part
  when :chorus
    2.times do
      pp [:am, :c, :g, :am, :am, :am, :am]
      pp [:g, :g, :am, :am]
      pp [:am, :c, :g, :am, :am, :am, :am]
      pp [:g, :g, :em, :am]
    end
  when :verse
    2.times do
      pp [:am, :g, :c, :am]
      pp [:g, :em, :am, :am]
    end
  end
end

live_loop :drums do
  sync_bpm :tick
  sync :pp_bar
  with_fx :compressor, amp: $drum_amp do
    with_fx :reverb do
      in_thread do
        4.times do
          sample :drum_cymbal_pedal, amp: 0.75
          sleep 0.25
        end
      end unless $first_bar
      if $last_bar then
        in_thread do
          sample :bd_zome, rate: 0.75
          sleep 1.0 / 8
          sample :sn_zome
          sleep 1.0 / 4
          sample :sn_zome
          sleep 1.0 / 4
          sample :sn_zome
        end
      else
        in_thread do
          sample :bd_zome, rate: 0.75
          sleep 1.0 / 2
          sample :sn_zome
          sleep 3.0 / 8
          sample :sn_zome
        end
      end
    end
  end
end
