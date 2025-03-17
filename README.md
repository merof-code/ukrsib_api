# UkrsibApi

This gem is an API wrapper for the Ukrsib bank Business API. It is currently a work in progress. For more details, see the [changelog](CHANGELOG.md).

API documentation can be found [here](USB_API_insrt_v_1.0.22.pdf).

This project uses `dry-transformers` and `dry-schema` to provide proper names for API fields. See the model files in the `/models` directory and the mapping from the original fields in the `/transformers` directory. For example, see the [v3/statements transformer](lib/ukrsib_api/transformers/statement_v3_transformer.rb) and [v3/statements model](lib/ukrsib_api/models/statement_v3.rb).


<!-- ## Money Field Mappings

Certain fields in the API responses can be handled as Money using the Money gem. These fields are available in various formats depending on the context. Below are some examples: -->

<!-- ### Balances

- **Standard Fields:**
  - `balance_in` and `balance_in_uah`
  - `balance_out` and `balance_out_uah`
  - `turnover_debt` and `turnover_debt_uah`
  - `turnover_cred` and `turnover_cred_uah`
- **Money Gem Fields:**  
  The same fields may also appear with an additional `_money` suffix (e.g., `balance_in_money`), providing a Money-formatted version. -->

<!-- ### Satements v3

- **Standard Amount Fields:**
  - `money_amount_uah`
  - `money_amount`
- **Money Gem Fields:**
  - `amount_uah_money`
  - `amount_money` -->

## Installation

Follow the installation instructions provided in the main guide to add and use the gem in your application.

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add ukrsib_api
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install ukrsib_api
```

## Usage

To use the API, you need to initialize the authentication with your api credentials, then get the tokens via browser login.
Here is a basic example of how to list balances:

## Setup: Initiating Connection

To initiate the connection with the API:
1. Instantiate the authentication object with your private key and client parameters.
2. Call `@auth.authorize` to initiate OAuth2 authorization. [See the docs](lib/ukrsib_api/authentication.rb#)   This returns a hash with a `:client_code` and a redirection `:location`.
3. Open the provided URL in an external browser and log in.
4. Retrieve the client code from the returned hash.
5. Call `@auth.fetch_token(client_code: your_client_code)` to complete the initial login and obtain the access token.
6. save your tokens! Save the results of the `auth.fetch_token` and use it later to refresh without browser login. 

```ruby
client_params = { client_id:, client_secret:}
private_key = File.read("ukrsibbankRsaPrivateKey.pem")
@auth = UkrsibAPI::Authentication.new(private_key:, client_params:)
@client = UkrsibAPI::Client.new(authentication: @auth)
r = @auth.authorize
#=> {:client_code=>"8adb342b-d107-4bbc-a2ef-aa3ce1b75898",
# :location=>"https://business.ukrsibbank.com/login?client_id=D1...6B&response_type=code&state=null&client_code=8adb342b-d107-4bbc-a2ef-aa3ce1b75898"}
@auth.fetch_token(client_code: r[:client_code])
# I, [2025-03-17T17:50:23.772351 #16957]  INFO -- UkrsibAPI: New access token retrieved. Expires at: 2025-03-18 17:50:23 +0000
#=> {:access_token=> :refresh_token=> :expires_at=>2025-03-18 17:50:23.77188235 +0000}
r = @client.statements_v3.list(accounts: ["UA..._UAH"], date_from: last_month, date_to: today)
```

To restart later 
```ruby 
tokens = @auth.fetch_token(client_code: r[:client_code])
# save the tokens!
....
@auth = UkrsibAPI::Authentication.new(private_key:, client_params:, tokens:) # use tokens here
@client = UkrsibAPI::Client.new(authentication: @auth)
```

## Getting statements
```ruby
client.statements_v3.list(accounts: ["UA..._UAH"], date_from: last_month, date_to: today)
```
add currency to your ibans after an underscore. `_UAH`, `_USD` 


## Feature: Lazy Loading Pagination

All API methods internally use lazy loading to handle paginated results. By leveraging Ruby's Enumerator, the gem fetches data on-demand

## Logging

UkrsibAPI's has configurable logging logging is configured in [ukrsib_api.rb](./lib/ukrsib_api.rb). The logger uses Rails.logger if available, otherwise defaults to a standard Ruby Logger writing to STDOUT with a custom formatter that includes abbreviated severity, a timestamp with microseconds, and process details.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Development Environment

This project includes a development container configuration. To use it, you need to have Visual Studio Code and the Remote - Containers extension installed. You can open the project in a dev container by clicking the badge below:

[![Open in Dev Containers](https://img.shields.io/static/v1?label=Dev%20Containers&message=Open&color=blue&logo=visualstudiocode)](https://vscode.dev/redirect?url=vscode://ms-vscode-remote.remote-containers/cloneInVolume?url=https://github.com/merof-code/ukrsib_api)

### Using bin/console

To use the API from the interactive console (`bin/console`), you need to add your own API key. Create a file named `environment.rb` in the root directory and add your API key there. You can use the provided `environment.sample.rb` as a template by renaming it to `environment.rb` and replacing the placeholder with your actual API key.

```ruby
# environment.rb
ENV['API_TOKEN'] = 'your_api_key_here'
```

Once inside the console, you can use the `@client` object to interact with the API. For example, to list balances:

```ruby
balances = @client.balance.list(@today)
balances.each do |balance|
  puts balance.account
  puts balance.balance_in_money.format
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/merof-code/ukrsib_api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/merof-code/ukrsib_api/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the UkrsibApi project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/merof-code/ukrsib_api/blob/master/CODE_OF_CONDUCT.md).
