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
require_relative 'gitbar_app/config/setup.rb'
require_relative 'gitbar_app/view.rb'
require_relative 'gitbar_app/controller.rb'

# Setup
IS_CONNECTED = Setup.check_connection
GH_PATH = Setup.gh_path
# gh is then used to get Username, Current Status of each repo and Pull Requests
USERNAME = Setup.fetch_username
SETTINGS = Setup.load_settings
# Loading a backup view in case connection is down
FULL_VIEW_ARRAY = Setup.load_full_view_array

if IS_CONNECTED
  # Loading repositories data
  controller = Controller.new(repositories_data: SETTINGS['repositories'])
  repositories = controller.fetch_repositories # will fetch repos using `gh`

  # Displaying the menu and repositories, full_view_array is preloaded from the json file.
  # If we have some data, the array will be refreshed
  view = View.new(repositories: repositories, full_view_array: [])
  view.prepare_full_view # Will update full_view_array
  controller.persist_view(view: view) # Will update view.json with what's in full_view_array
else
  # In case connection is lost, we need to display something instead of a timeout error (breaking the plugin).
  view = View.new(repositories: [], full_view_array: FULL_VIEW_ARRAY, offline: true)
end

view.display # Will display whatever is in full_view_array
