#!/usr/bin/env ruby

# <xbar.title>Github Pull Requests</xbar.title>
# <xbar.version>v0.1</xbar.version>
# <xbar.author>Paul Lahana</xbar.author>
# <xbar.author.github>paultursuru</xbar.author.github>
# <xbar.desc>Github Pull Request Viewer</xbar.desc>
# <xbar.dependencies>ruby, nokogiri</xbar.dependencies>

<<<<<<< HEAD
require_relative 'gitbar_app/models/repository.rb'
require_relative 'gitbar_app/view.rb'

settings = JSON.parse(File.read('gitbar_app/config/settings.json'))
repositories = settings['repositories'].map { |repo| Repository.new(name: repo['name']) }
USERNAME = settings['username']
view = View.new(repositories: repositories)
view.start

=======
require 'json'
require 'date'

# CONTROLLER
def fetch_pull_requests
  output = `/opt/homebrew/bin/gh pr list --repo #{REPO} --state open --json title,number,url,reviewRequests,author,updatedAt,mergeable,statusCheckRollup`
  JSON.parse(output)
end

def review_requested?(review_requests)
  review_requests.any? { |request| request['login'] == USERNAME }
end

def review_requested_prs
  PULL_REQUESTS.select { |pr| review_requested?(pr['reviewRequests']) }
end

def reviewed_prs
  PULL_REQUESTS.reject { |pr| review_requested?(pr['reviewRequests']) }
end

def my_prs
  PULL_REQUESTS.select { |pr| is_mine?(pr) }
end

def is_mine?(pr)
  pr['author']['login'] == USERNAME
end

# HELPERS
def main_status_icon
  return '😊' if REVIEW_REQUESTED_PRS.empty?

  if REVIEW_REQUESTED_PRS.count < 2
    '🟠'
  else
    '🔴'
  end
end

def mergeable_icon(pr)
  case pr['mergeable']
  when 'MERGEABLE'
    '🟢'
  when 'CONFLICTING'
    '🔴'
  else
    '🟠'
  end
end

def status_icon(pr)
  case pr['statusCheckRollup'][0]['state']
  when 'SUCCESS'
    '🟢'
  when 'FAILURE'
    '🔴'
  else
    '🟠'
  end
end

def status_text(pr)
  "#{pr['statusCheckRollup'][0]['state'].downcase.capitalize} #{pr['statusCheckRollup'][0]['context']}"
end

def mergeable_icon(pr)
  case pr['mergeable']
  when 'MERGEABLE'
    '🟢'
  when 'CONFLICTING'
    '🔴'
  else
    '🟠'
  end
end

def mergeable_text(pr)
  pr['mergeable'].downcase.capitalize
end

def format_pr(pr)
  "#{pr['title'].chars.first(40).join}#{pr['title'].chars.length > 40 ? '...' : ''} by #{pr['author']['login']} (##{pr['number']})"
end

def time_since(updated_at)
  date_now = DateTime.now
  date_updated = DateTime.parse(updated_at)
  difference_in_minutes = ((date_now - date_updated) * 24 * 60).to_i
  if difference_in_minutes < 60
    "Dernier update il y a #{difference_in_minutes} minutes"
  elsif difference_in_minutes < 60 * 24
    "Dernier update il y a #{difference_in_minutes / 60} heures"
  else
    "Dernier update il y a #{difference_in_minutes / 60 / 24} jours"
  end
end

# VIEW
def insert_line(body:, level: 0, icon: nil, options: {})
  full_text = "#{'--' * level}"
  full_text += " #{icon}" if icon
  full_text += " #{body}"
  full_text += " |" if options.any?
  options.each do |key, value|
    full_text += " #{key}=#{value}"
  end
  puts full_text
end

def separator
  puts "---"
end

def display_menu
  insert_line(body: "#{main_status_icon} #{REPO}", level: 0)
end

def format_pull_requests
  display_prs(pr: REVIEW_REQUESTED_PRS, title: 'review requested', emoji: '👀', to_review: true)
  separator
  display_prs(pr: REVIEWED_PRS, emoji: '👍', title: 'reviewed')
  separator
  display_prs(pr: MY_PRS, emoji: '🤓', title: 'owned open PRs')
end

def display_prs(pr:, title:, emoji: '👍', to_review: false)
  insert_line(body: "#{pr.count} #{title.gsub("\n", ' ')}", level: 0, icon: emoji)
  pr.each do |pr|
    insert_line(body: format_pr(pr), level: 1)
    insert_line(body: "Check this PR", level: 2, icon: '🔗', options: { href: pr['url'] })
    insert_line(body: status_text(pr), level: 2, icon: status_icon(pr), options: { color: 'yellow' })
    insert_line(body: mergeable_text(pr), level: 2, icon: mergeable_icon(pr), options: { color: 'yellow' })
    insert_line(body: time_since(pr['updatedAt']), level: 2) if to_review
  end
end

# CONFIG
REPO = 'mvaragnat/wemind'
USERNAME = 'paultursuru'
PULL_REQUESTS = fetch_pull_requests
REVIEW_REQUESTED_PRS = review_requested_prs
REVIEWED_PRS = reviewed_prs
MY_PRS = my_prs

# start the app
display_menu
separator
format_pull_requests
>>>>>>> 28ed64c (refactos)
