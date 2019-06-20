# Add a lead for the baseline.

def base(n, t)
  play n, sustain: t, attack: 1.0/16, release: 1.0/16
  sleep t
end

live_loop :drums do
  sample :bd_haus
  sleep 0.5
end

live_loop :baseline do
  sync :drums
  use_synth :fm
  base :d3, 2.0/3
  base :f3, 1.0/6
  base :d3, 1.0/6

  base :a3, 2.0/3
  base :g3, 1.0/6
  base :f3, 1.0/6

  base :e3, 2.0/3
  base :f3, 1.0/6
  base :e3, 1.0/6

  base :d3, 1
end
