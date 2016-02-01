require "to_elixir/version"

module ToElixir
  class MyRailtie < Rails::Railtie
    rake_tasks do
      load "to_elixir.rake"
    end
  end
end
