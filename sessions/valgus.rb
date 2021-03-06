define :pchord do |r, c, bass=nil, nosleep: false|
  notes = chord(r, c)
  c_bass = (bass.nil? ? notes[0] : bass)
  keyboard notes + [c_bass]

  with_fx :reverb, amp: 1.0 do
    with_fx :slicer, amp: 0.5 do
      with_synth :pulse do
        play c_bass - 12, release: 2
        play c_bass - 24, release: 3
      end

      with_synth :beep do
        at line(0, 2) do |_, i|
          play c_bass - 12 + i*12
        end
      end
    end
  end

  with_fx :level, amp: 1.0 do
    with_synth :dsaw do 
      at line(0, 2, steps:3) do
        play_chord notes, release: 0.5
        play_chord notes+0.15, release: 0.5, amp: 0.5
        play_chord notes+0.3, release: 0.5, amp: 0.25
      end
    end
  end

  sleep 2.0 unless nosleep
end

define :pchords do |chords, bass=nil, nosleep: false|
  chords.each_with_index do |(r, c), i|
    pchord(r, c, bass, nosleep: (i == chords.length - 1 and nosleep))
  end
end

live_loop :chords do
  sync_bpm :tock

  2.times do |i|
    case i
    when 0
      puts "ärevas vaikuses seisab üks väike maja"
    when 1
      puts "kuid hingamiskahinat on kuulda säält"
    end
    pchords([
      [:g, :M], [:f, :M], [:c, :M], [:g, :M], 
    ], :g)
  end

  puts "kas on keegi eksind teelt"
  pchords([
    [:e, :m], [:d, :M], [:c, :M],
    [:d, :M], [:e, :m],
    [:d, :M], [:c, :M],
    [:c, :M],
  ], :e)

  puts "või on viirastuse need"
  pchords([
    [:e, :m],
    [:d, :M],
    [:c, :M],
  ], :e)
  pchord(:d, :M, :g)

  puts "õud saladuslik näib"
  pchords([
    [:e, :m],
    [:d, :M],
    [:c, :M],
    [:d, :M],
  ], :e, nosleep: true)
end

live_loop :drums do
  sync_bpm :tock

  with_fx :lpf, cutoff: :c9 do
    with_fx :distortion, distort: 0.8, amp: 0.6 do
      at [0, 2] do
        at line(0, 1) do |t, i|
          sample :bd_haus, amp: line(1, 0)[i]**2
        end
      end
    end
    with_fx :reverb do
      at [1, 3] do
        at [0, 2.0/3] do |t, i|
          sample :sn_zome, amp: [0.75, 1][i]
        end
      end
    end
  end
end

live_loop :lyrics do
  sync_bpm :chords
  with_fx :distortion, distort: 0.8, amp: 0 do
    live_audio_loop "valgus_maja", 16, take: 5, beep: 1.0
    live_audio_loop "valgus_eksind", 16, take: 5, beep: 1.0
    live_audio_loop "valgus_viirastus", 16, take: 6, beep: 1.0, nosleep: true
  end
end

vj_osc "/repeat"

live_loop :tock do
  vj_bpm
  vj_seek

  if tick(:tock) == 0 then
    sleep 1.0
    cue :tock
  end

  4.times do
    cue :tick
    sleep 1
  end
end
