# Feedback

$drum_amp = 1.0
$drum_feedback = 0.3
$drum_reverb_mix = 0.3
$drum_record = true

$blip_amp = 0.0

$blip_bitcrusher_mix = 0.3
$blip_record = true
$slicer_amp = 0.3
$chord_amp = 0.1

live_loop :bar do
  if tick(:bar) == 0 then
    sleep 1.0
    cue :bar
  end

  4.times do
    cue :tock
    4.times do
      cue :tick
      sleep 1.0
    end
  end
end

def nuke_buffers(name, count)
  # Zero out the buffers
  (0...count).map { |i|
    buf = buffer("#{name}#{i}", 0.01)
    with_fx :record, buffer: buf do
      sleep 0.01
    end
  }
end
if false then
  nuke_buffers(:drums, 4)
  nuke_buffers(:blips, 4)
end

def make_buffers(name, count, length)
  # Make buffers for looping back
  (0...count).map { |i|
    buffer("#{name}#{i}", length)
  }
end

def maybe_record(bufs, record: false)
  # Re-record one of the buffers
  if record then
    buf = bufs.delete_at(rand_i(bufs.length))
    puts "recording #{buf.path.split("/")[-1]}"
    with_fx :record, buffer: buf do
      yield
    end
  else
    yield
  end
end

def play_cuts(bufs, length, cuts, amp: 1.0)
  # Cut up one of the buffers and play pieces back in shuffled order
  play_buf = bufs.choose
  puts "playing #{play_buf.path.split("/")[-1]}"
  at line(0, length, steps: cuts), (0...cuts).to_a.shuffle do |s|
    sample play_buf, start: s.to_f/length, finish: (s.to_f + length.to_f/cuts)/length, amp: amp
  end
end

live_loop :drums do
  sync_bpm :tock

  bufs = make_buffers(:drums, 4, 4)
  with_fx :bitcrusher, mix: 0.3, amp: $drum_amp do
    maybe_record bufs, record: $drum_record do
      at [0] do
        sample :bd_haus
      end

      case tick(:snare) % 4
      when 0
        at line(2, 3, steps: 6) do
          sample [:bd_haus, :sn_zome].choose, amp: 0.7
        end
      when 3
        at line(2, 4, steps: 32) do
          sample [:bd_haus, :sn_zome].choose, amp: 0.5
        end
      when [1, 3]
        at [2, 2.5, 3, 3.75] do
          sample [:bd_haus, :sn_zome].choose
        end
      end

      with_fx :reverb, mix: $drum_reverb_mix do
        with_fx :pitch_shift, pitch: [0, -6, 6].choose do
          play_cuts bufs, 4, 8, amp: $drum_feedback
        end
      end
    end
  end
end

def b(n, t)
  # Base sound
  4.times do
    play n + rand(0.1), attack: rand(t/4), sustain: t/2+rand(1), release: rand(t/4), amp: 0.7+rand(0.3)
  end
  play n-12, sustain: t, amp: 0.3
  with_fx :slicer do
    play n+12, release: t, amp: $slicer_amp
  end
end

live_loop :blips do
  sync_bpm :bar

  bufs = make_buffers(:blips, 4, 16)

  with_fx :reverb, amp: $blip_amp do
    maybe_record bufs, record: $blip_record do
      with_synth :fm do
        # Play a progression
        at *[
          [0, [:a2, 4]],
          [4, [:c3, 4]],
          [8, [:e3, 4]],
          [12, [:a2, 4]],
        ].transpose do |(n, t)|
          b n, t
        end

        # Play notes from a chord
        notes = [
          chord(:a3, :m7),
          chord(:g4, :maj),
        ].choose.shuffle
        at 8.times.map {
          base = rand_i(4) * 4
          case rand_i(2)
          when 0
            base + rand_i(3) * 1.0/3
          when 1
            base + rand_i(4) * 1.0/4
          end
        }, notes do |n|
          puts "chord note #{keyboard_keys([n])}"
          with_fx :level, amp: $chord_amp do
            b n, 1.0
          end
        end
      end

      with_fx :bitcrusher, mix: $blip_bitcrusher_mix, rate: 20000 do
        play_cuts bufs, 16, 16, amp: $blip_feedback
      end
    end
  end
end
