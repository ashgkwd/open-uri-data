# frozen_string_literal: true

require "test_helper"

class TestOpenURIData < Minitest::Test
  def setup
    @plain = ::OpenURIData::Mediatype.new(type: "text/plain")
    @png = ::OpenURIData::Mediatype.new(type: "image/png")
    @gif = ::OpenURIData::Mediatype.new(type: "image/gif")
    @html = ::OpenURIData::Mediatype.new(type: "text/html")
  end

  def test_that_it_has_a_version_number
    refute_nil ::URI::Data::VERSION
  end

  def test_parses_plain_text
    sample = "data:text/plain,Hello%20World"
    expected = ::OpenURIData::DataURI.new(mediatype: @plain, base64: false, data: "Hello%20World")
    assert_equal expected, ::OpenURIData.parse(sample)
  end

  def test_parses_base64_png
    sample = "data:image/png;base64,U2FtcGxlIFBORyBJbWFnZQ=="
    expected = ::OpenURIData::DataURI.new(mediatype: @png, base64: true, data: "U2FtcGxlIFBORyBJbWFnZQ==")
    assert_equal expected, ::OpenURIData.parse(sample)
  end

  def test_parses_base64_gif_rfc2739
    data = %(R0lGODdhMAAwAPAAAAAAAP///ywAAAAAMAAw
    AAAC8IyPqcvt3wCcDkiLc7C0qwyGHhSWpjQu5yqmCYsapyuvUUlvONmOZtfzgFz
    ByTB10QgxOR0TqBQejhRNzOfkVJ+5YiUqrXF5Y5lKh/DeuNcP5yLWGsEbtLiOSp
    a/TPg7JpJHxyendzWTBfX0cxOnKPjgBzi4diinWGdkF8kjdfnycQZXZeYGejmJl
    ZeGl9i2icVqaNVailT6F5iJ90m6mvuTS4OK05M0vDk0Q4XUtwvKOzrcd3iq9uis
    F81M1OIcR7lEewwcLp7tuNNkM3uNna3F2JQFo97Vriy/Xl4/f1cf5VWzXyym7PH
    hhx4dbgYKAAA7).tr("\n", "").tr(" ", "")
    sample = "data:image/gif;base64,#{data}"
    expected = ::OpenURIData::DataURI.new(mediatype: @gif, base64: true, data: data)
    assert_equal expected, ::OpenURIData.parse(sample)
  end

  def test_parses_base64_text
    sample = "data:;base64,SGVsbG8gV29ybGQg8J-Ri_Cfp5HigI3wn5K7"

    expected = ::OpenURIData::DataURI.new(mediatype: @plain, base64: true, data: "SGVsbG8gV29ybGQg8J-Ri_Cfp5HigI3wn5K7")
    assert_equal expected, ::OpenURIData.parse(sample)
  end

  def test_parses_another_text
    sample = "data:text/html,<a%20href=https://www.example.in>Visit%20example.re</a>"
    expected = ::OpenURIData::DataURI.new(mediatype: @html, base64: false, data: "<a%20href=https://www.example.in>Visit%20example.re</a>")
    assert_equal expected, ::OpenURIData.parse(sample)
  end

  def test_parses_text_with_params
    sample = "data:text/plain;charset=utf-8,Hello%20World"
    mediatype = ::OpenURIData::Mediatype.new(type: "text/plain", parameters: {"charset" => "utf-8"})
    expected = ::OpenURIData::DataURI.new(mediatype: mediatype, base64: false, data: "Hello%20World")
    assert_equal expected, ::OpenURIData.parse(sample)
  end

  def test_parses_text_with_params_rfc2739
    sample = "data:text/plain;charset=iso-8859-7,%be%fg%be"
    mediatype = ::OpenURIData::Mediatype.new(type: "text/plain", parameters: {"charset" => "iso-8859-7"})
    expected = ::OpenURIData::DataURI.new(mediatype: mediatype, base64: false, data: "%be%fg%be")
    assert_equal expected, ::OpenURIData.parse(sample)
  end

  def test_parses_text_with_params_and_base64
    sample = "data:text/plain;charset=iso-8859-7;base64,JWJlJWZnJWJl"
    mediatype = ::OpenURIData::Mediatype.new(type: "text/plain", parameters: {"charset" => "iso-8859-7"})
    expected = ::OpenURIData::DataURI.new(mediatype: mediatype, base64: true, data: "JWJlJWZnJWJl")
    assert_equal expected, ::OpenURIData.parse(sample)
  end

  def test_decodes
    sample = ::OpenURIData::DataURI.new(mediatype: @plain, base64: true, data: "SGVsbG8gV29ybGQ=")
    assert_equal "Hello World".encode(Encoding::UTF_8), sample.decode!
  end

  def test_decodes_urlsafe
    sample = ::OpenURIData::DataURI.new(mediatype: @plain, base64: true, data: "SGVsbG8rV29ybGQhL21vcmU_dGV4dA==")
    assert_equal "Hello+World!/more?text".encode(Encoding::UTF_8), sample.decode!(urlsafe: true)
  end
end
