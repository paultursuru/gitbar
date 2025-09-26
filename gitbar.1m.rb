#!/usr/bin/env ruby

# <xbar.title>Github Pull Requests</xbar.title>
# <xbar.version>v0.1</xbar.version>
# <xbar.author>Paul Lahana</xbar.author>
# <xbar.author.github>paultursuru</xbar.author.github>
# <xbar.desc>Github Pull Request Viewer</xbar.desc>
# <xbar.dependencies>ruby, nokogiri</xbar.dependencies>

# Technically, this file is re-executed every 1m (as the name implies)
# You can change the refresh rate by changing the "1m" in the name of this file to any other time value 10s, 2h, etc

require 'json'
require_relative 'gitbar_app/models/repository.rb'
require_relative 'gitbar_app/view.rb'
require_relative 'gitbar_app/repositories_controller.rb'

# Loading repositories list
settings_path = File.join(__dir__, 'gitbar_app', 'config', 'settings.json')
settings = JSON.parse(File.read(settings_path))

USERNAME = settings['username']

# Loading the last persisted view in case the connection is lost.
full_view_path = File.join(__dir__, 'gitbar_app', 'config', 'view.json')
File.write(full_view_path, []) unless File.exist?(full_view_path)
full_view_array = JSON.parse(File.read(full_view_path))

# Checking connection - sending only one packet
ping_to_gh = `ping -c 1 github.com`

if !ping_to_gh.empty? # Ping failed
  # Loading repositories data
  repositories_controller = RepositoriesController.new(repositories_data: settings['repositories'])
  repositories = repositories_controller.fetch_repositories # will fetch repos using `gh`

  # Displaying the menu and repositories, full_view_array is preloaded from the json file.
  # If we have some data, the array will be refreshed
  view = View.new(repositories: repositories, full_view_array: [])
  view.prepare_full_view # Will update full_view_array
  repositories_controller.persists_view(view: view) # Will update view.json with what's in full_view_array
else
  # In case you lose connection, we need to display something instead of a timeout error braking the plugin.
  view = View.new(repositories: [], full_view_array: full_view_array, offline: true)
end

view.display # Will display whatever is in full_view_array
