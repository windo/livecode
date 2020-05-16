def keyboard_keys(notes)
  underline = "\u0332"
  white = "\u25a1"
  black = "\u25a0"

  numeric = notes.map { |n| note(n) }
  first = (numeric.min / 12) * 12
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

def keyboard(notes)
  puts keyboard_keys(notes)
end

use_random_seed(status[:avg_cpu]*100000)

case rand_i(2)
when 0
  r = scale(:c, :chromatic).choose
  c = chord_names.choose
  n = chord r, c
  keyboard(n)
  puts note_info(r).midi_string, c
  puts n
  play_chord n
when 1
  r = scale(:c, :chromatic).choose
  s = scale_names.choose
  n = scale(r, s)
  keyboard(n)
  puts note_info(r).midi_string, s
  puts n
  play_pattern_timed n, 0.1
end
