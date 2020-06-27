set :_midi_input, '*'

define :play_midi do |&block|
  live_loop :_play_midi, init: {} do |last|
    use_real_time

    n, v = sync "/midi:#{get :_midi_input}/note_on"

    if v == 0 then
      if last.include? n then
        if last[n].kind_of?(Array) then
          last[n].each do |s|
            control s, amp: 0
          end
        else
          control last[n], amp: 0
        end
        last.delete n
      end
    else
      # I'd like to do ~infinite sustain but there is no way to actually cancel
      # a note?
      sustain = 8
      last[n] = block.call(n, sustain: sustain, amp: v.to_f/127, amp_slide: 0.1)
    end

    last
  end
end

define :record_midi do |duration, time_quantum: 0.25, velocity_quantum: 0.2|
  start = vt
  times = []
  notes = []
  velocities = []
  durations = []
  playing = {}

  name = "_record_midi_#{vt}".to_sym
  live_loop name do
    n, v = sync "/midi:#{get :_midi_input}/note_on"
    t = vt - start - current_sched_ahead_time
    t = (t / time_quantum).round * time_quantum
    d = nil

    if v == 0 then
      if not playing[n].nil? then
        playing[n][0] = t - playing[n][0]
        playing.delete(n)
      end
      next
    else
      d = [t]
      playing[n] = d
    end

    if t >= duration then
      if times.length > 0 then
        puts "times = " + times.to_s
        puts "notes = " + notes.to_s
        puts "velocities = " + velocities.to_s
        puts "durations = " + durations.map { |d| d[0] }.to_s
      end
      stop
    else
      times << t
      notes << note_info(n).midi_string.downcase.to_sym
      velocities << (((v.to_f / 127) / velocity_quantum).round * velocity_quantum).round(4)
      durations << d
    end
  end
end
