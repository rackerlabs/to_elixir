namespace :to_elixir do
  desc "Generate Rails migration for created_at timestamps"
  task :timestamps => :environment do
    time = Time.now.strftime('%Y%m%d%H%M%S')

    File.open "#{Rails.root}/db/migrate/#{time}_convert_timestamps.rb", "wb" do |f|
      f.write %{class ConvertTimestamps < ActiveRecord::Migration
  def up
    ActiveRecord::Base.connection.tables.each do |t|
      begin
        columns = t.classify.constantize.columns.map(&:name)

        if columns.include?("created_at")
          rename_column t.to_sym, :created_at, :inserted_at
        end
      rescue
        puts "\#{t} failed."
      end
    end
  end

  def down
    ActiveRecord::Base.connection.tables.each do |t|
      begin
        columns = t.classify.constantize.columns.map(&:name)

        if columns.include?("inserted_at")
          rename_column t.to_sym, :inserted_at, :created_at
        end
      rescue
        puts "\#{t} failed."
      end
    end
  end
end
      }
    end
  end


  desc "Generate Phoenix files from DB"
  task :phoenix => :environment do
    raise "No APP_NAME?" unless name = ENV['APP_NAME']

    name          = name.downcase
    forget_list   = %w{id updated_at created_at}
    table_info    = []

    `rm -rf #{Dir.pwd}/#{name}`

    puts "Creating #{name} Phoenix project"
    `yes | mix phoenix.new #{name}`

    puts "Creating DB"
    Dir.chdir name
    `mix ecto.create`

    ActiveRecord::Base.connection.tables.each do |table|
      begin
        klass_name = table.singularize.camelize
        klass      = klass_name.constantize
        obj_name   = klass_name.tableize.singularize
        columns    = klass.columns
                      .reject{ |c| forget_list.include?(c.name) }
                      .map{ |c| "#{c.name}:#{c.type}" }
                      .join(" ")

        puts "Mixing #{klass_name}..."
        `sleep 1 && mix phoenix.gen.json #{klass_name} #{obj_name.pluralize} #{columns}`
        table_info << [klass_name, obj_name]
      rescue
        puts "Not able to convert #{table}"
      end
    end

    app_name     = name.capitalize
    router_path  = "#{Dir.pwd}/web/router.ex"
    routes       = table_info.map{ |(k,o)| "\t\tresources \"/#{o.pluralize}\", #{k}Controller\n" }.join
    template     = %{defmodule #{app_name}.Router do
  use #{app_name}.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", #{app_name} do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", #{app_name} do
    pipe_through :api
    #{routes}
  end
end}

    File.write(router_path, template)

    `mix ecto.migrate`
  end
end
