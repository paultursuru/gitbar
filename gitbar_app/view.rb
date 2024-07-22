require_relative 'helpers/application_helper.rb'

class View
  include ApplicationHelper

  def initialize(repositories: [])
    @repositories = repositories
  end

  def start
    display_menu
    separator
    display_repositories
  end
  
  def display_menu
    insert_line(body: "#{main_status_icon(repository: @repositories.first)} #{main_status_text(repository: @repositories.first)}", level: 0, options: { size: 12 })
  end

  def insert_line(body:, level: 0, icon: nil, options: {})
    full_text = "#{'--' * level}"
    full_text += " #{icon}" if icon
    full_text += " #{body}"
    options[:size] = 11 if options[:size].nil?
    full_text += " |" if options.any?
    full_text += " #{options.map { |key, value| "#{key}=#{value}" }.join(' ')}"
    puts full_text
  end
  
  def separator
    puts "---"
  end

  def display_repositories
    @repositories.each do |repository|
      display_repository(repository: repository)
      separator
    end
  end
  
  def display_repository(repository:)
    insert_line(body: repository.name, level: 0, icon: status_icon(status: repository.status), options: { size: 13, href: repository.url })
    repository.status_details.each do |detail|
      insert_line(body: detail['description'], level: 1, icon: status_icon(status: detail['state']), options: { href: detail['target_url'] })
      insert_line(body: time_since(detail['created_at']), level: 1)
    end
    display_pull_requests(repository: repository)
  end

  def display_pull_requests(repository:)
    display_prs(prs_data: repository.review_requested_prs, title: 'review requested', icon: '👀', to_review: true)
    display_prs(prs_data: repository.reviewed_prs, icon: '👍', title: 'already reviewed')
    display_prs(prs_data: repository.my_prs, icon: '🤓', title: 'owned open PRs')
  end
  
  def display_prs(prs_data:, title:, icon: '👍', to_review: false)
    insert_line(body: "#{prs_data.count} #{title.gsub("\n", ' ')}", level: 0, icon: icon)
    prs_data.each do |pr|
      insert_line(body: format_pr(pr), level: 1, icon: '🔗',options: { href: pr.url })
      insert_reviews(pr)
      insert_line(body: status_text(pr), level: 2, icon: status_icon(status: pr.status_check_rollup_state), options: { color: status_color(pr), href: pr.status_check_rollup })
      insert_line(body: mergeable_text(pr), level: 2, icon: status_icon(status: pr.mergeable), options: { color: mergeable_color(pr) })
      insert_line(body: time_since(pr.updated_at), level: 2) if to_review
    end
  end

  def insert_reviews(pr)
    insert_line(body: "no reviews yet", level: 2, icon: '🤷‍♀️') and return if pr.reviews.empty?
  
    pr.reviews.group_by { |review| review.author }.each do |login, reviews|
      insert_line(body: "#{reviews.last.state.downcase.capitalize.gsub('_', ' ')} by #{login}", level: 2, icon: review_icon(reviews.last), options: { color: review_color(reviews.last) })
    end
  end
end