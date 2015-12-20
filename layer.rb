require './neuron.rb'

class Layer

  attr_accessor :type, :neurons, :bias, :options

  def initialize(options={})
    self.options = options
    self.type = options[:type] ? options[:type].to_sym : :hidden
    self.neurons = []
    self.bias = nil
    build_neurons
  end

  def build_neurons
    neurons_or_count = self.options[:neurons]
    case neurons_or_count
    when Integer
      neurons_or_count.times do
        opts = {}
        opts.merge!({force_weight: self.options[:force_weight]}) if self.options[:force_weight]
        self.neurons << Neuron.new(opts)
      end
    when Array
      raise StandardError.new('Layer neurons are not all of Neuron class') if neurons_or_count.collect { |n| !n.is_a?(Neuron)}.any?
      self.neurons = neurons_or_count
    end
  end

  # connects this layer neurons (sources) to another layer neurons (targets)
  def connect(target_layer)
    add_bias
    neurons_and_bias.each do |n|
      n.connect(target_layer.neurons)
    end
  end

  def neurons_and_bias
    neurons + [bias].compact
  end

  def activate(inputs)    
    feed(inputs)
  end

  # splat here lets you send an array or multple args
  def feed(*inputs)
    input_array = Array[inputs].flatten # force our splat arg to an Array
    outputs = []
    neurons.each_with_index do |neuron, idx|      
      outputs << neuron.activate(input_array[idx] || next)
    end
    outputs
  end

  def add_bias
    self.bias = Neuron.new(is_bias: true) if self.bias.nil?
  end

  def output
    self.neurons.collect { |n| n.output }
  end

  # in case we want to see normal inspect, because we are going to override it below
  (alias_method :inspect_normal, :inspect) unless $reloading

  def inspect
    self.to_s
  end

  def to_s
    "\n #{self.type.capitalize} Layer #{object_id}\n" +
    "  " + neurons.join("\n  ").to_s
  end

end