define :vj_osc do |address, *args|
  osc_send "127.0.0.1", 7770, address, *args
end

define :vj_bpm do |bpm=nil|
  if bpm.nil? then
    bpm = current_bpm
  end
  with_real_time do
    vj_osc "/rate", (bpm.to_f / 60)
  end
end

define :vj_track do |track=nil|
  if track.nil?
    track = rand_i 100
  end
  vj_osc "/track", track
end

define :vj_seek do |t=0.0|
  with_sched_ahead_time(-0.1) do
    vj_osc "/seek", t
  end
end

# Always want this.
vj_osc "/repeat"
