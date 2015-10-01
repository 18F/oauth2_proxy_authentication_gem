# `oauth2_proxy_authentication` gem

**NOTE: This gem will not work until after bitly/oauth2_proxy#147 is integrated.**

Authenticates requests from
[bitly/oauth2_proxy](https://github.com/bitly/oauth2_proxy) based on a
shared-secret HMAC signature of the request.

## Installation

If you're using [Bundler](http://bundler.io) in your project, add the
following to your `Gemfile`:

```ruby
gem 'oauth2_proxy_authentication'
```

If you're not using Bundler, start.

## Usage

Inject something resembling the following code fragment into your request
handling logic as the first thing that happens before the request body is
parsed, where `secret_key` is the shared secret between your application and
the running instance of `bitly/oauth2_proxy`:

```ruby
def my_handler(request)
  result, header_signature, computed_signature = (
    Oauth2ProxyAuthentication.validate_request(request, secret_key))
  if result != Oauth2ProxyAuthentication::MATCH
    # Cancel the request, optionally logging the values above.
  end
end
```

## Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0
>dedication. By submitting a pull request, you are agreeing to comply
>with this waiver of copyright interest.
