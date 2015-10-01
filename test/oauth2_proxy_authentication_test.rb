require_relative 'test_helper'
require_relative '../lib/oauth2_proxy_authentication'

require 'minitest/autorun'
require 'net/http'
require 'openssl'

module Oauth2ProxyAuthentication
  class RequestSignatureTest < ::Minitest::Test
    attr_accessor :digest

    def setup
      @digest = OpenSSL::Digest.new 'sha1'
    end

    # rubocop:disable MethodLength
    # rubocop:disable Metrics/AbcSize
    def test_request_signature_post
      uri = URI 'http://localhost/foo/bar'
      req = Net::HTTP::Post.new uri
      payload = '{ "hello": "world!" }'
      req.body = payload
      req.content_type = 'application/json'
      req['Content-Length'] = req.body.size
      req['Content-MD5'] = 'deadbeef'
      req['Date'] = '2015-09-28'
      req['Authorization'] = 'trust me'
      req['X-Forwarded-User'] = 'mbland'
      req['X-Forwarded-Email'] = 'mbland@acm.org'
      req['X-Forwarded-Access-Token'] = 'feedbead'
      req['Cookie'] = 'foo; bar; baz=quux'
      req['Gap-Auth'] = 'mbland'

      assert_equal(
        ['POST',
         "#{payload.size}",
         'deadbeef',
         'application/json',
         '2015-09-28',
         'trust me',
         'mbland',
         'mbland@acm.org',
         'feedbead',
         'foo; bar; baz=quux',
         'mbland',
         '/foo/bar',
        ].join("\n"),
        Oauth2ProxyAuthentication.string_to_sign(req))
      assert_equal(
        'sha1 722UbRYfC6MnjtIxqEJMDPrW2mk=',
        Oauth2ProxyAuthentication.request_signature(req, digest, 'foobar'))
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable MethodLength

    # rubocop:disable MethodLength
    def test_request_signature_get
      uri = URI 'http://localhost/foo/bar'
      req = Net::HTTP::Get.new uri
      req['Date'] = '2015-09-29'
      req['Cookie'] = 'foo; bar; baz=quux'
      req['Gap-Auth'] = 'mbland'

      assert_equal(
        ['GET',
         '',
         '',
         '',
         '2015-09-29',
         '',
         '',
         '',
         '',
         'foo; bar; baz=quux',
         'mbland',
         '/foo/bar',
        ].join("\n"),
        Oauth2ProxyAuthentication.string_to_sign(req))

      assert_equal(
        'sha1 JBQJcmSTteQyHZXFUA9glis9BIk=',
        Oauth2ProxyAuthentication.request_signature(req, digest, 'foobar'))
    end
    # rubocop:enable MethodLength
  end

  class ValidateRequestTest < ::Minitest::Test
    attr_accessor :uri, :request, :digest

    def setup
      @uri = URI 'http://localhost/foo/bar'
      @request = Net::HTTP::Post.new uri
      @digest = OpenSSL::Digest.new 'sha1'
    end

    def request_signature(secret_key)
      Oauth2ProxyAuthentication.request_signature request, digest, secret_key
    end

    def validate_request(secret_key)
      Oauth2ProxyAuthentication.validate_request request, secret_key
    end

    def test_validate_request_no_signature
      result, header, computed = validate_request 'foobar'
      assert_equal Oauth2ProxyAuthentication::NO_SIGNATURE, result
      assert_nil header
      assert_nil computed
    end

    def test_validate_request_invalid_format
      bad_value = 'should be algorithm and digest value'
      request['GAP-Signature'] = bad_value
      result, header, computed = validate_request 'foobar'
      assert_equal Oauth2ProxyAuthentication::INVALID_FORMAT, result
      assert_equal bad_value, header
      assert_nil computed
    end

    def test_validate_request_unsupported_algorithm
      valid_signature = request_signature 'foobar'
      components = valid_signature.split ' '
      signature_with_unsupported_algorithm = "unsupported #{components.last}"
      request['GAP-Signature'] = signature_with_unsupported_algorithm
      result, header, computed = validate_request 'foobar'
      assert_equal Oauth2ProxyAuthentication::UNSUPPORTED_ALGORITHM, result
      assert_equal signature_with_unsupported_algorithm, header
      assert_nil computed
    end

    def test_validate_request_match
      expected_signature = request_signature 'foobar'
      request['GAP-Signature'] = expected_signature
      result, header, computed = validate_request 'foobar'
      assert_equal Oauth2ProxyAuthentication::MATCH, result
      assert_equal expected_signature, header
      assert_equal expected_signature, computed
    end

    def test_validate_request_mismatch
      foobar_signature = request_signature 'foobar'
      barbaz_signature = request_signature 'barbaz'
      request['GAP-Signature'] = foobar_signature
      result, header, computed = validate_request 'barbaz'
      assert_equal Oauth2ProxyAuthentication::MISMATCH, result
      assert_equal foobar_signature, header
      assert_equal barbaz_signature, computed
    end
  end
end
