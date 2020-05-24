def _get_steps()
  # Produce potential step sizes in numbers of beats.
  #
  # Consider combinations of powers of 2 and 3, from 1/50 up to 50.

  steps_of_2 = (0..5).map { |i| 2**i }
  steps_of_3 = (0..3).map { |i| 3**i }
  steps = steps_of_2.product(steps_of_3).select { |i, j| i * j <= 50 }
  steps = steps.concat(steps.map { |i, j| [1.0/i, 1.0/j] })
  steps.sort_by! { |i, j| -(i * j) }
end

def _fit(n, steps: nil)
  if steps.nil? then
    steps = _get_steps
  end
  # Find the largest step size that fits evenly into the beat offset
  steps.find { |i, j|
    fit = n.to_f / (i * j).to_f
    (fit - fit.round).abs < 1e-5
  }
end

def rythm_slots(times, offset: 0, meter: 2)
  # Visualize the timestamps as a "drum machine" beat track. Tries to guess the
  # meter for the beat track - basic combinations of multiples of 2 and 3 are
  # supported.
  #
  # Example:
  #
  # times = ]0.0, 0.75, 1.0, 2.0, 2.5, 3.0]
  # puts rythm_slots(times)
  # 1/4: |●··●|●···|●·●·|●···|

  beat_symbol = "\u25cf"  # black circle
  empty_symbol = "\u00b7"  # middle dot
  times_array = times.to_a.map { |t| (t - offset).round(6) }

  steps = _get_steps
  step_req = times_array.map { |n|
    _fit(n, steps: steps)
  }
  step_components = [
    step_req.map { |i, j| i }.min,
    step_req.map { |i, j| j }.min,
  ]
  step = (
    step_components[0] * step_components[1]
  )

  start_time = 0
  raise 'No end time' unless times_array.max
  finish_time = 2 ** (Math.log(times_array.max, meter) + 1).to_i

  sequence = "#{Rational(step).rationalize(1e-3)}: "
  i = start_time
  splits = (finish_time / step) >= 16
  while i < finish_time
    if splits then
      quarters = i.to_f / (finish_time.to_f / 4)
      if (quarters - quarters.round).abs < 1e-5 then
        sequence += '|'
      end
    end
    if times_array.include?(i.round(6)) then
      sequence += beat_symbol
    else
      sequence += empty_symbol
    end
    i += step
  end
  if splits then
    sequence += '|'
  end
  return sequence
end

def rythm(times, offset: 0, meter: 2)
  puts rythm_slots(times, offset: offset, meter: meter)
end

# rythm(line(0, 4))
# rythm([1, 3])
# rythm([0, 4, 8, 9, 12])
# rythm([0, 2, 4, 8, 11, 12])
# rythm([0, 4, 4 + 4.0/3, 8, 12, 14])
# rythm(line(0, 8, steps: 8) + line(1.5, 4.5))

times = (line(0, 4) + [0.75, 2.5]).sort
puts times
puts rythm_slots(times)
