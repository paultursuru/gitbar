#!/usr/bin/env ruby

# <xbar.title>Github Pull Requests</xbar.title>
# <xbar.version>v0.1</xbar.version>
# <xbar.author>Paul Lahana</xbar.author>
# <xbar.author.github>paultursuru</xbar.author.github>
# <xbar.desc>Github Pull Request Viewer</xbar.desc>
# <xbar.dependencies>ruby, nokogiri</xbar.dependencies>

require 'json'
require 'date'

# CONTROLLER
def fetch_pull_requests
  output = `/opt/homebrew/bin/gh pr list --repo #{REPO} --state open --json title,number,url,reviews,reviewRequests,author,updatedAt,mergeable,statusCheckRollup`
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
  return '😊' if MY_PRS.empty? || MY_PRS.all? { |pr| pr['reviews'].empty? }

  groups = MY_PRS.group_by { |pr| can_be_merged(pr) }
  refused_count = groups[false] ? groups[false].count { |pr| pr['reviews'].any? { |review| review['state'] == 'CHANGES_REQUESTED' } } : 0
  groups[true] ? (groups[true].count > refused_count ? '🟢' : '🔴') : '🟠'
end

def main_status_text
  return 'No open PRs' if MY_PRS.empty?

  groups = MY_PRS.group_by { |pr| can_be_merged(pr) }
  true_count = groups[true] ? groups[true].count : 0
  false_count = groups[false] ? groups[false].count { |pr| pr['reviews'].any? { |review| review['state'] == 'CHANGES_REQUESTED' } } : 0
  text = "#{true_count} of your PRs #{true_count > 1 ? 'are' : 'is'} mergeable"
  text += " and #{false_count} waiting for review" if false_count > 0
  text
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

def status_color(pr)
  case pr['statusCheckRollup'][0]['state']
  when 'SUCCESS'
    'green'
  when 'FAILURE'
    'red'
  else
    'yellow'
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
  case pr['mergeable']
  when 'MERGEABLE'
    'No conflict'
  when 'CONFLICTING'
    'Conflicts'
  else
    pr['mergeable'].downcase.capitalize
  end
end

def mergeable_color(pr)
  case pr['mergeable']
  when 'MERGEABLE'
    'green'
  when 'CONFLICTING'
    'red'
  else
    'yellow'
  end
end

def review_icon(pr_review)
  case pr_review['state']
  when 'APPROVED'
    '✅'
  when 'CHANGES_REQUESTED'
    '❌'
  else
    '⚠️'
  end
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
  insert_line(body: "#{main_status_icon} #{main_status_text}", level: 0)
end

def format_pull_requests
  display_prs(pr: REVIEW_REQUESTED_PRS, title: 'review requested', icon: '👀', to_review: true)
  separator
  display_prs(pr: REVIEWED_PRS, icon: '👍', title: 'reviewed')
  separator
  display_prs(pr: MY_PRS, icon: '🤓', title: 'owned open PRs')
end

def display_prs(pr:, title:, icon: '👍', to_review: false)
  insert_line(body: "#{pr.count} #{title.gsub("\n", ' ')}", level: 0, icon: icon)
  pr.each do |pr|
    insert_line(body: format_pr(pr), level: 1, icon: '🔗',options: { href: pr['url'] })
    insert_reviews(pr)
    insert_line(body: status_text(pr), level: 2, icon: status_icon(pr), options: { color: status_color(pr), href: pr['statusCheckRollup'][0]['targetUrl'] })
    insert_line(body: mergeable_text(pr), level: 2, icon: mergeable_icon(pr), options: { color: mergeable_color(pr) })
    insert_line(body: time_since(pr['updatedAt']), level: 2) if to_review
  end
end

def insert_reviews(pr)
  insert_line(body: "no reviews yet", level: 2, icon: '🤷‍♀️') and return if pr['reviews'].empty?

  pr['reviews'].group_by { |review| review['author']['login'] }.each do |login, reviews|
    case reviews.last['state']
    when 'APPROVED'
      text_color = 'green'
    when 'CHANGES_REQUESTED'
      text_color = 'red'
    else
      text_color = 'yellow'
    end
    insert_line(body: "#{reviews.last['state'].downcase.capitalize.gsub('_', ' ')} by #{login}", level: 2, icon: review_icon(reviews.last), options: { color: text_color })
  end
end

def can_be_merged(pr)
  return false unless pr['mergeable'] == 'MERGEABLE' && pr['reviews'].any?

  pr['reviews'].group_by { |review| review['author']['login'] }.each do |login, reviews|
    return false if reviews.last['state'] == 'CHANGES_REQUESTED'

    return reviews.last['state'] == 'APPROVED'
  end
  nil
end

# CONFIG
settings = JSON.parse(File.read('config/settings.json'))
REPO = settings['repo']
USERNAME = settings['username']
PULL_REQUESTS = fetch_pull_requests
REVIEW_REQUESTED_PRS = review_requested_prs
REVIEWED_PRS = reviewed_prs
MY_PRS = my_prs

# start the app
display_menu
separator
format_pull_requests