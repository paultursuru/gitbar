#!/usr/bin/env ruby

# <xbar.title>Github Pull Requests</xbar.title>
# <xbar.version>v0.1</xbar.version>
# <xbar.author>Paul Lahana</xbar.author>
# <xbar.author.github>paultursuru</xbar.author.github>
# <xbar.desc>Github Pull Request Viewer</xbar.desc>
# <xbar.dependencies>ruby, nokogiri</xbar.dependencies>

require_relative 'gitbar_app/models/repository.rb'
require_relative 'gitbar_app/view.rb'

settings = JSON.parse(File.read('gitbar_app/config/settings.json'))
repositories = settings['repositories'].map { |repo| Repository.new(name: repo['name']) }
USERNAME = settings['username']
view = View.new(repositories: repositories)
view.start

