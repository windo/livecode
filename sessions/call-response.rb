define :update_state do |state|
  if state.nil? then
    state = {
      phase: :intro,
      since: vt,
    }
  end
  state
end

live_loop :conductor, init: nil do |state|
  if tick(:tock) == 0 then
    sleep 1
  end

  trace_sync
  cue :line
  4.times do
    cue :bar
    4.times do
      state = update_state state
      cue :beat
      sleep 1.0
    end
  end

  state
end

define :p do |n|
  with_synth :sine do
    3.times do |d|
      with_synth_defaults attack: 0.01, amp: line(0.5, 0.1, steps: 3)[d] do
        play n+d*0.03+rand(0.01)
        play n-d*0.03-rand(0.01)
      end
    end
    with_synth_defaults attack: 0.01, release: 0.3 do
      play n-12, amp: 0.5
      play n-24, amp: 0.25
    end
  end
end

define :pc do |s, ni, nd|
  ni = ni.sort
  c = [s[ni[0] + nd]]
  ni.to_a.slice(1, ni.length).each do |i|
    n = s[i + nd]
    if n > c.slice(-1) + 2 then
      c << n
    end
  end
  c = ring(*c.slice(0, 4))
  puts c

  at [0, 2.5, 3.5] do |_, i|
    trace_note :chord, c
    d = 2.5
    d = 0.75 if i != 0
    with_synth_defaults attack: 0.01, release: d do
      with_synth :dsaw do
        play_chord c, amp: 1.0
      end
      with_synth :subpulse do
        play_chord c-12, amp: 0.2
      end
    end
  end
end

define :walk do |ni, steps, target, initial_d: nil|
  last = ni.slice(-1)
  d = target - last
  initial_d = d if initial_d.nil?

  counts = ni.inject(Hash.new(0)) do |memo, e|
    memo[e] = memo[e] + 1
    memo
  end

  ni_next = last + d/steps + rand(initial_d/steps) - initial_d/steps/2
  if (ni_next - last).abs < 1 then
    ni_next += rdist 1
  end
  ni_next = -6 if ni_next < -6
  if counts[ni_next.round] > 1 then
    ni_next += rdist 2
  end
  ni_next = -6 if ni_next < -6
  ni_new = ni.clone
  ni_new << ni_next.round

  if steps > 1 then
    return walk ni_new, steps-1, target, initial_d: initial_d
  else
    return ni_new
  end
end

ll :call, 8, :bar do
  o = [4, 5].choose
  sn = [:minor, :major].choose
  s = scale(:c3, sn, num_octaves: 3) + (o-4)*12
  nd = 8
  ni = walk([0], 3, rdist(8).round)
  ni = walk(ni, 3, rdist(8).round)
  puts "call", ni

  at line(0, 4, steps: 8).to_a.slice(0, 7) do |_, i|
    n = s[ni[i] + nd]
    trace_note :call, n
    p n
  end

  pc s, ni, nd
  at [4] do
    cue :response, {sn: sn, ni: ni.freeze, o: o, nd: nd}
  end
end

ll :response, 8, :response do |_, md|
  md = md.to_h
  puts md
  sn = md[:sn]
  o = md[:o]
  ni = md[:ni]
  nd = md[:nd]
  case rand_i 3
  when 0
    scales = [:major, :minor, :mixolydian, :phrygian].collect do |csn|
      s = scale(:c, sn)
      cs = scale(:c, csn)
      diffs = ni.count { |i| s[i] != cs[i] }
      [csn, diffs]
    end.sort_by { |csn, diffs| diffs }
    sn = scales.slice(-1)[0]
    puts "scale", sn
  when 1
    ni = walk [ni[0]], 3, rdist(8).round
    ni = walk ni, 3, rdist(8).round
    puts "new notes", ni
  when 2
    nd += rdist(4).round
    puts "transpose", nd
  else
    puts "nop"
  end

  s = scale(:c3, sn, num_octaves: 3) + (o-4)*12
  pc s, ni, nd
  at line(0, 4, steps: 8).to_a.slice(0, 7) do |_, i|
    n = s[ni[i] + nd]
    trace_note :response, n
    p n
  end
end

define :bd do
  trace_drum :bd
  sample :bd_haus
end

define :sn do
  trace_drum :sn
  sample :sn_zome
end

define :hh do
  trace_drum :hh, 0.1
  sample :drum_cymbal_pedal, amp: 0.8 + rand(0.2)
end

ll :drums, 4, :bar do
  at [0, 0.75, 1.5, 2.75] do
    bd
  end
  at [1, 3] do
    sn
  end
  at line(0, 4, steps: 16) + [[ 3.875 ], [ 3.625, 3.875 ]].choose do
    hh
  end
end
