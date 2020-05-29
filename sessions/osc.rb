set :_osc_ip_port, "192.168.0.57:42812"
def on_osc(path)
  loop_name = "_osc_#{path}"
  live_loop loop_name do
    v = sync "/osc:#{get :_osc_ip_port}#{path}"
    yield v
  end
end

def osc_trigger(path)
  on_osc path do |v|
    if v[0] == 1.0 then
      yield
    end
  end
end

def osc_trigger_one(path)
  trigger_name = "_osc_#{path}_trigger"
  on_osc path do |v|
    if v[0] == 1.0 then
      in_thread name: trigger_name do
        yield
      end
    end
  end
end

def osc_set(path, key, default:0)
  if get(key).nil? then
    set key, default
  end
  on_osc path do |v|
    set key, v[0]
  end
end

osc_set("/1/fader1", :fader1)
osc_set("/1/fader2", :fader2)
osc_set("/1/fader3", :fader3)
osc_set("/1/fader4", :fader4)

osc_trigger "/2/push1" do
  use_real_time
  sample :bd_haus
end

osc_trigger "/2/push2" do
  use_real_time
  sample :sn_zome
end

with_fx :reverb, mix:1.0, amp:1.0 do
  live_loop :pings1 do
    use_real_time
    play note(:a3), amp: get(:fader1)
    sleep 0.3
  end

  live_loop :pings2 do
    use_real_time
    play note(:c4), amp: get(:fader2)
    sleep 0.3
  end

  live_loop :pings3 do
    use_real_time
    play note(:e4), amp: get(:fader3)
    sleep 0.3
  end

  live_loop :pings4 do
    use_real_time
    play note(:g4), amp: get(:fader4)
    sleep 0.3
  end
end
