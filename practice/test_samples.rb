# Play some external samples!

def p(name)
  path = ""
  sample path, name
end

live_loop :tick do
  sleep 1.0
end

live_loop :sounds do
  sync :tick
end
