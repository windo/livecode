# Build up the drum pattern:
#   * Add/remove beats, vary timing
#   * Add/replace percussion samples, vary sample parameters
#   * Create multiple variations of the pattern(s)

live_loop :drums do
  at line(0, 4, steps: 16) do
    sample :drum_cymbal_open, sustain: 0.1, amp: 0.4
  end

  at [0, 2] do
    sample :bd_haus
  end
  at [1, 3] do
    sample :sn_zome
  end

  sleep 4
end
