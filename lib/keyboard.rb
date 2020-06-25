def keyboard_keys(notes, from: nil)
  underline = "\u0332"
  white = "\u25a1"
  black = "\u25a0"

  notes = [notes] if not notes.is_a? Array

  numeric = notes.map { |n| note(n) }
  minimum = numeric.min
  if not from.nil? and note(from) < minimum then
    minimum = note(from)
  end
  first = (minimum / 12) * 12
  last = (numeric.max / 12 + 1) * 12 - 1
  
  info = note_info(first)
  buf = info.midi_string + ": "
  (first..last).map do |n|
    if n % 12 == 0 && n != first then
      buf += "|"
    end
    if numeric.include?(n) then
      buf += underline
    end
    info = note_info(n)
    if info.midi_string.length == 2 then
      buf += white
    else
      buf += black
    end
  end

  return buf
end

def keyboard(*args, **kwargs)
  puts keyboard_keys(*args, **kwargs)
end
