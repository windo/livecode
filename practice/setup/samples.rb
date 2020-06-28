# Play some external samples!

define :p do |name, **kwargs|
  path = nil
  sample path, name, **kwargs
end

live_loop :sounds do
  sync :tick
end

live_loop :tick do
  sleep 1.0
end

