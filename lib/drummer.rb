require 'forwardable'

$sonic_pi = self
class Drummer
  extend Forwardable
  def_delegators :$sonic_pi, :sleep
  def_delegators :$sonic_pi, :__delayed_user_message

  def initialize(sample_map, length: 1.0)
    @sample_map = sample_map
    @length = length
    # [ {time => sample, ... }, ... ]
    @tracks = []
  end

  # Something like: "B-S- BBS-"
  def add(drum_pattern, bars: 1, pos: 0, length: 1)
    drum_pattern = drum_pattern.gsub(" ", "").split(//)
    bar_duration = @length.to_f / bars
    time = bar_duration * pos
    duration = bar_duration * length
    td = Hash.new
    drum_pattern.each_with_index { |sample, i|
      td[time + duration / drum_pattern.length * i] = sample
    }
    @tracks.push td
  end

  def play
    time = 0
    beats = Hash.new { |h, k| h[k] = Array.new }
    @tracks.each { |t|
      t.each_pair { |k, v| beats[k].push(v) }
    }
    beats.keys.sort.each do |t|
      sleep t - time
      time = t
      beats[t].each do |b|
        if @sample_map.has_key? b
          @sample_map[b].call
        end
      end
    end
    # sleep @length - time
  end
end
