# Add a baseline to the lead.

live_loop :lead do
  use_synth :prophet
  r = ring 2.0/3, 1.0/3
  [:e4, :c4, :a4, :g4, :f4, :g4, :e4, :a3].each do |n|
    at [0, 0.5], [0, 12] do |d|
      play n + d
    end
    sleep r[tick]
  end
end
