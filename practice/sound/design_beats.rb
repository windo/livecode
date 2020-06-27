# Design percussive instrument sounds

define :hh do |**kwargs|
  sample :drum_cymbal_open, sustain: 0.1, **kwargs
end

define :bd do |**kwargs|
  sample :bd_haus, **kwargs
end

define :sd do |**kwargs|
  sample :sn_zome, **kwargs
end

define :tom do |**kwargs|
  sample :drum_tom_mid_soft, **kwargs
end

define :ride do |**kwargs|
  sample :drum_splash_hard, **kwargs
end

live_loop :drums do
  at [
    line(0, 2, steps: 8),
    line(0, 2, steps: 8) + (line(1, 1.5, steps: 2) + 0.125),
    line(0, 1, steps: 4) + line(1, 2, steps: 3),
  ].choose do
    hh
  end

  at [
    [0],
    [0, 0.5],
    [0, 1.0/3, 2.0/3],
    [0, 1.75],
    line(0, 1),
  ].choose do
    bd
  end

  at [
    [1],
    [1, 1.5],
    [1, 1.75],
    line(1,2),
  ].choose do
    sd
  end

  if one_in(6) then
    at line(0, 2, steps: 16) do |t, i|
      tom rate: stretch(line(2, 1), 4)[i], amp: 0.7
    end
  end

  if one_in(3) then
    at [[0], [1], [1.75]].choose do
      ride
    end
  end

  sleep 2
end

puts all_sample_names.filter { |n| n.to_s.include?("drum") }
