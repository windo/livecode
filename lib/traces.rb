define :trace_osc do |path, *args, **kwargs|
  osc_send "127.0.0.1", 8765, path, *args, **kwargs
end

define :trace_single_note do |instrument, note, duration=1.0|
  note_name = note_info(note).midi_string
  trace_osc "/play", instrument.to_s, note_name, duration.to_f
end

define :trace_note do |instrument, notes, duration=1.0|
  case
  when notes.kind_of?(ring().class)
  when notes.kind_of?(Array)
  else
    notes = [notes]
  end

  notes.each do |n|
    trace_single_note instrument, n, duration
  end
end

define :trace_note_off do |instrument, note|
  note_name = note_info(note).midi_string
  trace_osc "/stop", instrument.to_s, note_name
end

define :trace_highlight do |notes|
  case
  when notes.kind_of?(ring().class)
  when notes.kind_of?(Array)
  else
    # Single note
    notes = [notes]
  end

  trace_osc "/highlight", *notes.map { |n| note_info(n).midi_string }
end

define :trace_drum do |instrument, duration=0.125|
  trace_osc "/drum", instrument.to_s, duration.to_f
end

define :trace_layer do |layer, duration=4, variant=""|
  trace_osc "/layer", layer.to_s, duration.to_f, variant.to_s
end

define :trace_sync do |bpm=nil|
  bpm = current_bpm if bpm.nil?
  trace_osc "/sync", bpm.to_i
end
