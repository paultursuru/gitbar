#!/usr/bin/env ruby

# <xbar.title>Github Pull Requests</xbar.title>
# <xbar.version>v0.1</xbar.version>
# <xbar.author>Paul Lahana</xbar.author>
# <xbar.author.github>paultursuru</xbar.author.github>
# <xbar.desc>Github Pull Request Viewer</xbar.desc>
# <xbar.dependencies>ruby, nokogiri</xbar.dependencies>

require 'json'
require 'date'

def fetch_pull_requests
  output = `/opt/homebrew/bin/gh pr list --repo #{REPO} --state open --json title,number,url,reviewRequests,author,updatedAt,mergeable`
  JSON.parse(output)
end

def review_requested?(review_requests)
  review_requests.any? { |request| request['login'] == USERNAME }
end

def format_pull_requests
  display_prs(pr: REVIEW_REQUESTED_PRS, title: 'review requested', emoji: '👀', to_review: true)
  separator
  display_prs(pr: REVIEWED_PRS, emoji: '👍', title: 'reviewed')
  separator
  display_prs(pr: MY_PRS, emoji: '🤓', title: 'owned open PRs')
end

def display_prs(pr:, title:, emoji: '👍', to_review: false)
  puts "#{emoji} #{pr.count} #{title.gsub("\n", ' ')}"
  pr.each do |pr|
    puts "-- #{mergeable_status_icon(pr['mergeable'])} #{pr['title'].chars.first(30).join}#{pr['title'].chars.length > 30 ? '...' : ''} by #{pr['author']['login']} (##{pr['number']})"
    puts "---- Check it out ! | href=#{pr['url']}"
    puts "---- #{mergeable_status_icon(pr['mergeable'])} #{mergeable_status_text(pr['mergeable'])}"
    time_since_last_update(pr['updatedAt']) if to_review
  end
  return nil
end

def time_since_last_update(updated_at)
  date_now = DateTime.now
  date_updated = DateTime.parse(updated_at)
  difference_in_minutes = ((date_now - date_updated) * 24 * 60).to_i
  if difference_in_minutes < 60
    puts "---- Dernier update il y a #{difference_in_minutes} minutes"
  elsif difference_in_minutes < 60 * 24
    puts "---- Dernier update il y a #{difference_in_minutes / 60} heures"
  else
    puts "---- Dernier update il y a #{difference_in_minutes / 60 / 24} jours"
  end
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

def main_status_icon
  return '😊' if REVIEW_REQUESTED_PRS.empty?

  if REVIEW_REQUESTED_PRS.count < 2
    '🟠'
  else
    '🔴'
  end
end

def mergeable_status_icon(mergeable)
  case mergeable
  when 'CONFLICTING'
    '🔴'
  when 'MERGEABLE'
    '🟠'
  else
    '🤷‍♀️'
  end
end

def separator
  puts "---"
end

def mergeable_status_text(mergeable)
  case mergeable
  when 'CONFLICTING'
    'conflict'
  when 'MERGEABLE'
    'mergeable'
  else
    'unknown'
  end
end

def display_menu
  puts "#{main_status_icon}"
  puts "---"
  puts format_pull_requests
end

REPO = 'mvaragnat/wemind'
USERNAME = 'paultursuru'
PULL_REQUESTS = fetch_pull_requests
REVIEW_REQUESTED_PRS = review_requested_prs
REVIEWED_PRS = reviewed_prs
MY_PRS = my_prs

# start the app
display_menu