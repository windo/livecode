# Spice up the drum pattern:
#   * Add/remove beats, vary timing
#   * Add/replace percussion samples, vary sample parameters
#   * Create multiple variations of the pattern(s)

live_loop :drums do
  in_thread do
    4.times do
      sample :drum_cymbal_open, sustain: 0.1, amp: 0.5
      sleep 0.25
    end
  end

  sample :bd_haus
  sleep 0.5
  sample :sn_zome
  sleep 0.5
end
