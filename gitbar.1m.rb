#!/usr/bin/env ruby

# <xbar.title>Github Pull Requests</xbar.title>
# <xbar.version>v0.1</xbar.version>
# <xbar.author>Paul Lahana</xbar.author>
# <xbar.author.github>paultursuru</xbar.author.github>
# <xbar.desc>Github Pull Request Viewer</xbar.desc>
# <xbar.dependencies>ruby, nokogiri</xbar.dependencies>

require 'json'
require_relative 'gitbar_app/models/repository.rb'
require_relative 'gitbar_app/view.rb'
require_relative 'gitbar_app/repositories_controller.rb'

# Loading repositories list
settings_path = File.join(__dir__, 'gitbar_app', 'config', 'settings.json')
settings = JSON.parse(File.read(settings_path))

USERNAME = settings['username']

# Loading repositories data
repositories = RepositoriesController.new(repositories_data: settings['repositories']).fetch_repositories

# Displaying the menu and repositories
view = View.new(repositories: repositories)

# Technically, this file is re-executed every 1m (as the name implies)
# You can change the refresh rate by changing the "1m" in the name of this file to any other time value 10s, 2h, etc
view.display # Refresh the header of the plugin and the repositories
