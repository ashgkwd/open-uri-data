# frozen_string_literal: true

require_relative "data/version"

module URI
  class Data < Generic
    COMPONENT = [:scheme, :opaque].freeze

    attr_reader :content_type, :data

    def initialize(*args)
      super(*args) unless args.length == 1

      uri = args.first.to_s
      unless /^data:/.match?(uri)
        raise URI::InvalidURIError.new("Invalid Data URI: " + args.first.inspect)
      end

      @scheme = OpenURIData::SCHEME
      @opaque = uri[5..]

      @data = OpenURIData.parse(@opaque).decode!
    end

    def open
      io = StringIO.new(data)
      OpenURI::Meta.init(io)
      io.meta_add_field("content-type", content_type)

      return io unless block_given?

      begin
        yield io
      ensure
        io.close
      end
    end

    def self.build(content, base64: true)
      data, content_type = case content
      when IO
        [content, nil]
      when Hash
        [arg[:data], arg[:content_type]]
      end

      raise ArgumentError.new("Expected IO or Hash with keys :data and :content_type. " + content.inspect) unless content

      if !content_type && data.respond_to?(:content_type)
        content_type = data.content_type
      end

      new(OpenURIData::SCHEME, nil, nil, nil, nil, nil, OpenURIData.to_opaque(content_type, base64, data), nil, nil)
    end
  end
end
