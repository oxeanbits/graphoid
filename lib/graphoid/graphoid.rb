require 'graphoid/driver/mongoid_driver'
require 'graphoid/scalars'
require 'graphoid/grapho'
require 'graphoid/graphield'

module Graphoid
  @graphs = {}

  class << self
    attr_reader :driver

    def initialize
      Graphoid.driver = configuration&.driver
      Graphoid::Scalars.generate
    end

    def build(model, _action = nil)
      @graphs[model] ||= Graphoid::Grapho.new(model)
    end

    def driver=(driver)
      #@driver = driver == :active_record ? ActiveRecordDriver : MongoidDriver
      @driver = MongoidDriver
    end
  end

  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
      Graphoid.initialize
    end
  end

  class Configuration
    attr_accessor :driver

    def initialize
      @driver = :mongoid
    end
  end
end
