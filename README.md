# to_elixir

to_elixir is a super simple Rails rake task that inspects your existing Rails application and generates a Elixir / Phoenix JSON API.

## Install

## Usage
`rake to_elixir:phoenix APP_NAME=<NAME>`

Where `<NAME>` is the name of your new Elixir app.
This will create a folder `<NAME>` in the root of your Rails application.
Simply run the command, wait a tick and then move the resulting folder somewhere else.
Enter the new Elixir app and run `iex -S mix phoenix.server` to boot your Elixir app.
Load up your new app at `http://localhost:4000/api/<EXISTING_RESOURCE_NAME>` and boom; simple json api.

## Want some quick data in that API?
`rake to_elixir:timestamps`

If you'd like to convert your existing Rails-based DB over to Phoenix just run the above command.
This will create a Rails migration that renames `:created_at` to `:inserted_at`
It can be rolled back (`rake db:rollback`) and is non-destructive.
Update `config/dev.exs` to point to your migrated Rails DB and viola; data in your simple json api.
