def nuke_buffers(name, count)
  # Zero out the buffers
  (0...count).map do |i|
    buf = buffer("#{name}#{i}", 0.01)
    with_fx :record, buffer: buf do
      sleep 0.01
    end
  end
end

def make_buffers(name, count, length)
  # Make buffers for looping back
  (0...count).map do |i|
    buffer("#{name}#{i}", length)
  end
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
  at line(0, length, steps: cuts), (0...cuts).to_a.shuffle do |cut|
    sample play_buf, start: cut.to_f/cuts, finish: (cut.to_f + 1)/cuts, amp: amp
  end
end
