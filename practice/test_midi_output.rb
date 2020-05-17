# Connect your hardware or software MIDI device!

# Send just this to stop the sound
midi_all_notes_off

def sound(n)
  port = ""
  with_midi_defaults port: port, channel: 0 do
    midi_note_on n
    in_thread do
      sleep 1
      midi_note_off n
    end
  end
end

live_loop :synth do
  s = shuffle(scale(:c, :minor_pentatonic))
  s.each do |n|
    sound(n)
    sleep 0.5
  end
end
