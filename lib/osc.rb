set :_osc_ip_port, "*"

def on_osc(path)
  with_real_time do
    loop_name = "_osc_#{path}"
    live_loop loop_name do
      cue_name = "/osc:#{get :_osc_ip_port}#{path}"
      puts cue_name
      v = sync cue_name
      yield v
    end
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
    puts key, v
    set key, v[0]
  end
end
