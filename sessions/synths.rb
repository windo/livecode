use_real_time

# Play a note while controlling some parameters from `get` variables
define :play_with_control do |n, d, c, k: 5, **kwargs|
  initial = kwargs.clone
  c.each.map do |par, var|
    [
      [par, get(var) || 0],
      ["#{par}_slide".to_sym, d.to_f/k ],
    ]
  end.flatten(1).each do |key, value|
    initial[key] = value
  end

  node = play(
    n, **initial
  )
  at line(0, d, steps: k) do
    params = {}
    c.each do |par, var|
      params[par] = get(var) || 0
    end
    control node, **params
  end
end

# Set variables from OSC messages
osc_set "/1/fader1", :fader1
osc_set "/1/fader2", :fader2
osc_set "/1/fader3", :fader3
osc_set "/1/fader4", :fader4


# Route OSC messages to control parameters
live_loop :router do
  k = 5
  set :detune, -12 + get(:fader1)
  set :cutoff, note(:c2) + get(:fader4) * note(:c7)
  sleep 1.0/k
end

# To try:
#   * subpulse, square-pulse, sine
#   * detuned: tri, pulse, saw
#   * fm
#   * mod: tri, pulse, saw, dsaw, sine, fm
#   * noise: brown, clip, pink, grey
#
# Notes:
#   * basic
#     * subpulse - play 2 notes
#     * square - pulse of 0.5
#     * sine - no cutoff :)
#   * detuned:
#     * low detune (.1 up to ~.3) sweeping sound
#     * high detune (.5+) pulsating
#     * cutoff exists :)
#     * dpulse: want the pulse close to 0.5
#   * fm:
#     * divisor > 5 pulsating
#     * divisor ~ 1 resonating, sweeping effect
#     * divisor < 1 ringing effect
#     * depth < 1 very soft
#     * depth > ~5 resonant pops
#   * mod:
#     * overall: arpeggio/melodic-cacophonic/slide device?
#     * other than quirky melody - use as modulated detune?
#     * dsaw: ~5 note modulation makes a dirty sound
#   * noise:
#     * bnoise: much lower profile than "static" noise?
#     * pnoise: lower profile than "static" noise?
#     * noise: static
#     * cnoise: intense?
#

# Trigger the synth over and over
live_loop :synth_test do
  use_bpm 100

  with_synth :sine do
    at line(0, 8), [:a1, :c2, :e2, :g2] do |n|
      play_with_control(
        n + 12, 2.5, {
          cutoff: :cutoff,
        },
        res: 1.0,
        sustain: 1.5,
      )
    end
  end

  sleep 8.0
end
