require 'base64'
require 'openssl'

module Oauth2ProxyAuthentication
  HEADERS = %w(
    Content-Length
    Content-Md5
    Content-Type
    Date
    Authorization
    X-Forwarded-User
    X-Forwarded-Email
    X-Forwarded-Access-Token
    Cookie
    Gap-Auth
  )

  NO_SIGNATURE = 1
  INVALID_FORMAT = 2
  UNSUPPORTED_ALGORITHM = 3
  MATCH = 4
  MISMATCH = 5

  def self.signed_headers(request)
    HEADERS.map { |name| request[name] || '' }
  end

  def self.string_to_sign(req)
    [req.method, signed_headers(req).join("\n"), req.uri.path].join("\n")
  end

  def self.request_signature(request, digest, secret_key)
    hmac = OpenSSL::HMAC.new secret_key, digest
    hmac << string_to_sign(request) << (request.body || '')
    digest.name.downcase + ' ' + Base64.strict_encode64(hmac.digest)
  end

  def self.parse_digest(name)
    OpenSSL::Digest.new name
  rescue
    nil
  end

  def self.validate_request(request, key)
    header = request['Gap-Signature']
    return NO_SIGNATURE unless header
    components = header.split ' '
    return INVALID_FORMAT, header unless components.size == 2
    digest = parse_digest components.first
    return UNSUPPORTED_ALGORITHM, header unless digest
    computed = request_signature(request, digest, key)
    [(header == computed) ? MATCH : MISMATCH, header, computed]
  end
end
