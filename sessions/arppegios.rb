$drums = 1
# :intro, :breakbeat, :banging
$drum_style = :intro

$walks = 1
# :main, :break
$walk_pattern = :main
# :arp, :single
$walk_style = :single

$sweeps = 0

live_loop :metronome do
  use_bpm 90

  if tick(:metronome) == 0 then
    sleep 1.0
    cue :metronome
  end

  cue :verse
  4.times do
    cue :bar
    4.times do
      cue :tick
      sleep 1
    end
  end
end

$play_scale = scale :a2, :minor, num_octaves:4

define :arp do |s, n, t, nosleep: false|
  play s[n]
  play s[n] - 12
  play s[n] - 24, amp: 0.5, release: 2
  play s[n] - 36, amp: 0.75, release: 4
  sleep t
  play s[n + 2]
  sleep t
  play s[n + 4]
  play s[n + 4] - 12
  play s[n + 4] - 24, amp: 0.5, release: 2
  sleep t
  play s[n + 2]
  sleep t unless nosleep
end

live_loop :walks do
  sync :verse, bpm_sync: true
  use_synth :saw
  case $walk_pattern
  when :main
    pattern = [
      0, 0, -1, 6,
      5, 5, 2, 1,
      0, 0, 3, 6,
      5, 6, 0, -1,
    ]
  when :break
    pattern = [
      0,  5, 4, 1,
      2,  3, 6, 3,
      0, -1, 2, 3,
      2,  6, 0, -1,
    ]
  end
  with_fx :compressor, amp: $walks do
    with_fx :reverb, damp: 0.8 do
      pattern.each_with_index do |i, idx|
        nosleep = (idx == pattern.length - 1)
        case $walk_style
        when :arp
          arp $play_scale, i+7, 0.25, nosleep: nosleep
        when :single
          play $play_scale[i+7]
          sleep 1 unless nosleep
        end
      end
    end
  end
end

define :psweep do |i, s, nosleep: false|
  detune = 0.8
  n = $play_scale[i + 7] - 12
  use_synth :pulse
  4.times do
    play n + rrand(0, detune) - detune / 2, release: s
  end
  play n - 12, release: s/2
  sleep s unless nosleep
end

live_loop :sweeps do
  sync_bpm :verse
  with_fx :compressor, amp: $sweeps do
    psweep 0, 8
    psweep 0, 8, nosleep: true
  end
end

live_loop :drums do
  sync_bpm :bar
  d = Drummer.new Hash[
    'b' => Proc.new {
      sample :drum_heavy_kick, amp: 8.0
    },
    's' => Proc.new {
      sample :drum_snare_hard, amp: 8.0
    },
    'h' => Proc.new {
      sample :drum_cymbal_soft , amp: 8.0, sustain: 0, release: 0.05
    }
  ], length: 4.0

  with_fx :compressor, amp: $drums do
    case $drum_style
    when :breakbeat
      d.add "b---s--s b---s-b- b---s--- b---s-ss"
      d.add "-b-", bars:4, pos:2
    when :banging
      d.add "bbsb"*3 + "-"*4
      d.add "bbb-b-sb", bars:4, pos:3
    when :intro
      d.add "ss-"
      d.add "---s"
      d.add "h"*8
    end
    d.play
  end
end
