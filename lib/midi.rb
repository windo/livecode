set :_midi_input, '*'

define :play_midi do |&block|
  live_loop :midi, init: {} do |last|
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
