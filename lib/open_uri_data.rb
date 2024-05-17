require "base64"
require "uri"

module OpenURIData
  Mediatype = Struct.new(:type, :parameters) do
    def initialize(type:, parameters: {})
      super(type: type, parameters: parameters)
    end
  end

  DataURI = Struct.new(:mediatype, :base64, :data, :decoded) do
    def initialize(mediatype:, base64:, data:, decoded: false)
      super(mediatype: mediatype, base64: base64, data: data, decoded: decoded)
    end

    def decode!(urlsafe: false)
      return data if decoded

      if base64
        self.data = if urlsafe
          Base64.urlsafe_decode64(data)
        else
          Base64.decode64(data)
        end
      end

      self.decoded = true
      data
    end
  end

  DEFAULT_MIME_TYPE = Mediatype.new(type: "text/plain")
  SCHEME = "data"

  module_function

  def to_opaque(content_type, data, base64: true)
    base64_part = base64 ? ";base64" : ""
    data_part = base64 ? Base64.urlsafe_encode64(data.read) : data.read
    "#{content_type}#{base64_part},#{data_part}"
  end
  alias_method :encode, :to_opaque

  def parse(data_uri)
    opaque = if data_uri.respond_to? :opaque
      data_uri.opaque
    elsif data_uri.start_with? "data:"
      data_uri[5..]
    end

    to_data_uri(opaque)
  end

  def to_data_uri(opaque)
    data_separator = opaque.index(",")
    data = opaque[(data_separator + 1)..]
    prefix = opaque[..(data_separator - 1)]
    base64 = prefix.end_with? ";base64"

    DataURI.new(mediatype: mediatype_from(prefix, base64), base64: base64, data: data)
  end

  def mediatype_from(prefix, base64)
    type_and_params = if base64
      prefix[...-7]
    else
      prefix[..-1]
    end

    return DEFAULT_MIME_TYPE if type_and_params.empty?

    type, *paramables = type_and_params.split(";")
    parameters = if paramables.empty?
      {}
    else
      paramables.map { |pair| URI.decode_www_form(pair).first }.to_h
    end

    Mediatype.new(type: type, parameters: parameters)
  end
end
