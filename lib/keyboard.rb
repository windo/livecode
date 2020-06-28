define :keyboard_keys do |notes, from: nil|
  underline = "\u0332"
  white = "\u25a1"
  black = "\u25a0"

  case
  when (notes.is_a? Array)
  when (notes.is_a? SonicPi::Core::RingVector)
    notes = notes.to_a
  when (notes.is_a? Numeric)
    notes = [notes]
  when (notes.is_a? Symbol)
    notes = [notes]
  else
    return notes.class.to_s
  end
  notes = notes.map { |n| note(n) }

  minimum = notes.min
  if not from.nil? and note(from) < minimum then
    minimum = note(from)
  end
  first = (minimum / 12) * 12
  last = (notes.max / 12 + 1) * 12 - 1
  
  info = note_info(first)
  buf = info.midi_string + ": "
  (first..last).map do |n|
    if n % 12 == 0 && n != first then
      buf += "|"
    end
    if notes.include?(n) then
      buf += underline
    end
    if [1,3,6,8,10].include?(n % 12) then
      buf += black
    else
      buf += white
    end
  end

  return buf
end

define :keyboard do |*args, **kwargs|
  puts keyboard_keys(*args, **kwargs)
end
