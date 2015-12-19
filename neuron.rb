require './connection.rb'

class Neuron
  
  attr_accessor :id, :options, :input, :output, :weight, :fire_threshold, :fired, :outgoing, :incoming, :is_bias
  @@count = 0
  @@report_with = nil

  def initialize(options={})
    self.options = {}
    self.input  = options[:input] || nil
    self.output = options[:output] || nil
    self.is_bias = options[:is_bias] && self.output = 1 || false
    self.fire_threshold = 0.5
    self.fired = false
    self.id = @@count += 1

    # connections
    self.incoming = []
    self.outgoing = []

    self.options.merge! options
  end

  def is_bias?
    self.is_bias
  end

  def activate(input=sum_connections)
    self.input = input
    raise "no input value was provided" if self.input.nil?

    if self.is_bias
      self.output = 1
    else
      self.output = activation_fn(self.input)
      if self.output > self.fire_threshold
	fire
      end
    end
    self.output
  end

  # sigmoid function basically exagerates the value between 0 and 1
  def activation_fn(input_value)
    1 / (1 + Math.exp(-input_value))
  end

  def sum_connections
    incoming.inject(0) {|sum,c| sum + (c.source.output * c.weight)} if incoming.any?
  end

  def fire
    self.fired = true
    outgoing.each do |c|
      c.target.activate(self.output)
    end
  end

  def fired?
    self.fired
  end

  # convenience method so you can set the weight
  def connect(*targets)
    targets.flatten.each do |target|
      connection = Connection.new(self, target, self.options[:force_weight])
      self.outgoing << connection
      # for now we only handle connections in one direction
      target.incoming << connection
    end
  end

  # convenience method so you can set a weight
  def connect_one(target, weight)
      connection = Connection.new(self, target, weight)
      self.outgoing << connection
      # for now we only handle connections in one direction
      target.incoming << connection
  end

  def connections
    outgoing + incoming
  end

  # in case we want to see normal inspect, because we are going to override it below
  (alias_method :inspect_normal, :inspect) unless $reloading

  def inspect
    to_s
  end

  def to_s
    s = "Neuron #{id} (IN: #{self.input || '__'} => OUT: #{self.output || '__'})" #+ "#{" *" if self.fired?}"
    s += report_connections if @@report_with == :connections
    s
  end

  def report_connections
    "\n  " + outgoing.join("\n  ").to_s
  end

  # type can be nil for just neuron IO, or :connections to include outgoing connections
  def self.report_with(type=nil)
    @@report_with = type.to_sym
  end

  def self.reset_counter
    @@count = 0
  end

  def self.count
    @@count || 0
  end
end
