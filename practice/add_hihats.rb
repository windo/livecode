# Add hihats at 4x the rate of base drums

live_loop :drums do
  4.times do
    sample :bd_haus
    sleep 1
  end
end
