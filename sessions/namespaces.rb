# 

define :with_ns do |name, &block|
  saved_ns = current_ns
  use_ns name
  block.call
  use_ns saved_ns
end

define :use_ns do |name|
  __system_thread_locals.set(:namespace, name)
end

define :current_ns do
  __system_thread_locals.get(:namespace)
end

define :ns_set do |name, value|
  key = (current_ns.to_s + name.to_s).to_sym
  set(key, value)
end

define :ns_get do |name|
  key = (current_ns.to_s + name.to_s).to_sym
  get(key)
end

live_loop :tock do
  sleep 4
end

live_loop :hey do
  sync :tock
  at(line(0, 4), [:c, :e, :g, :b]) do |n|
    play n, amp: get(:amp)
  end
end

time_warp(-0.001) do
  live_loop :control do
    sync :tock
    at(line(0, 4), [1, 0.25, 1, 0.25]) do |a|
      set :amp, a
    end
  end
end
