# Chronicle::Zulip
[![Gem Version](https://badge.fury.io/rb/chronicle-zulip.svg)](https://badge.fury.io/rb/chronicle-zulip)

Extract your Zulip messages using the command line with this plugin for [chronicle-etl](https://github.com/chronicle-app/chronicle-etl).

## Usage

```sh
# Install chronicle-etl and this plugin
$ gem install chronicle-etl
$ chronicle-etl plugins:install zulip
```

You can get a personal access token by going to Settings -> Account & Privacy and pressing the "Show/change your API key".

```sh
# Save username, access_token, and realm
$ chronicle-etl secrets:set zulip username foo@gmail.com
$ chronicle-etl secrets:set zulip access_token ACCESS_TOKEN
$ chronicle-etl secrets:set zulip realm foo

# Then, retrieve your private messages
$ chronicle-etl --extractor zulip:private-message --loader json
```

## Available Connectors
### Extractors

#### `private-messages`

Extractor for importing private messages from Zulip

##### Settings

- `username`: The email address associated with your Zulip account
- `access_token`: Your personal access token
- `realm`: ____.zulipchat.com

### Transformers

#### `message`

Transform a Zulip message into Chronicle Schema