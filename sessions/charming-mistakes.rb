# baseline, blips off, bpm 50, base drums only, max_cutoff 60
# blips on, cutoff 60 -> 90
# bpm 50 -> 60
# hihats, snare
# :placeholder, 0.9
# play with wave, cutoffs
# rand_*, cutoff 120

# drums 0, :break
# drums_full 1, :regular (break transition)
# play octaves -> 3
# full_drums -> false
# drums off
# blips off
# :break
# stop

$bpm = 55

$drums = 1
$hihats = false
$snare = false
$full_drums = true

$baseline = 0.8
# :placeholder, :regular, :break, :break_final
$baseline_type = :regular

$blips = 1
$rand_wave = false
$rand_res = false
$rand_cutoff = false
$max_cutoff = 90
$wave = 0
$octaves = 3

# break transition:
#$baseline_type = :regular; $drums = 1; $full_drums = true

live_loop :metronome do
  use_bpm $bpm
  cue :tock
  4.times do
    cue :tick
    sleep 1.0
  end
end

live_loop :drums do
  sync_bpm :tock
  d = Drummer.new Hash[
    "b" => Proc.new do
      sample :drum_bass_hard
    end,
    "s" => Proc.new do
      sample :drum_snare_hard
    end,
    "h" => Proc.new do
      sample :drum_cymbal_open, amp: 0.3, sustain_level: 0.3
    end
  ], length: 4

  d.add "bs"*4 unless $full_drums
  d.add "b--b s-b- bbb- s-ss b--b s-s- bb-b s--s" if $full_drums
  d.add "s", 32, 31 if ($snare && !$full_drums)
  d.add "h"*16 if $hihats

  with_fx :compressor, amp: $drums do
    with_fx :reverb, room: 0.3, damp: 1.0 do
      d.play
    end
  end
end

live_loop :blips do
  sync_bpm :tock
  use_synth :tb303
  if tick % 4 then
    rand_wave = rand_i(2)
  end
  with_fx :compressor, amp: $blips do
    with_fx :reverb do
      with_fx :echo do
        16.times do |i|
          play (scale :c3, :minor_pentatonic, num_octaves: $octaves).choose,
            amp: 0.4,
            release: 0.25,
            wave: (if $rand_wave then rand_wave else $wave end),
            cutoff: (if $rand_cutoff then rrand(60, $max_cutoff) else $max_cutoff end),
            res: (if $rand_res then rrand(0.6, 0.85) else 0.85 end)
          sleep 0.25 unless i == 15
        end
      end
    end
  end
end

def pbase(n, l=1.0)
  s = scale :c2, :minor_pentatonic, num_octaves: 2
  use_synth :tri
  play s[n], release: 4.0 * l, amp: 0.5
  play s[n]-12, release: 2.0 * l, amp: 0.25
  use_synth :fm
  play s[n]+12, release: 1.5 * l, amp: 0.8
end

live_loop :baseline do
  sync_bpm :tock
  with_fx :compressor, amp: $baseline do
    with_fx :krush do
      with_fx :reverb do
        case $baseline_type
        when :placeholder
          pbase 0
        when :regular
          pbase 3
          sleep 2
          pbase 2
          sleep 2
          pbase 0
          # sleep 4
        when :break, :break_final
          6.times do
            pbase 0, 0.1
            sleep 0.5
          end
          3.times do
            pbase 4, 0.05
            sleep 1.0/3.01
          end
          if $baseline_type == :break_final then
            # Extra sleep to make the stop easier to time
            sleep 1
          end
        end
      end
    end
  end
end
