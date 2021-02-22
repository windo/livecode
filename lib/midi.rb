set :_midi_input, '*'

define :on_midi_control do |midi_input=nil, &block|
  live_loop :_midi_contol do
    use_real_time
    midi_input = get(:_midi_input) if midi_input.nil?

    c, v = sync "/midi:#{midi_input}/control_change"
    block.call(c, v)
  end
end

define :play_midi do |midi_input=nil, &block|
  live_loop :_play_midi, init: {} do |last|
    use_real_time

    midi_input = get(:_midi_input) if midi_input.nil?

    n, v = sync "/midi:#{midi_input}/note_on"

    note_off = lambda do |n|
      case
      when n.kind_of?(Array)
        n.each do |n|
          note_off.call(n)
        end
      when n.is_a?(Proc)
        n.call
      when (n.class.name == 'SonicPi::SynthNode')  # Don't have access to class
        control n, amp: 0
      else
        puts "how to stop a #{n.class.name}?"
      end
    end

    if v == 0 then
      if last.include? n then
        note_off.call(last[n])
        last.delete n
      end
    else
      # I'd like to do ~infinite sustain but there is no way to actually cancel
      # a note?
      sustain = 8
      amp = v.to_f/127
      last[n] = block.call(n, sustain: sustain, amp: amp, amp_slide: 0.1, vel_f: amp, last: last)
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
