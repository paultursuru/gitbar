require_relative 'helpers/application_helper.rb'

# View
# Renders SwiftBar/BitBar/Xbar output for repositories and pull requests.
class View
  include ApplicationHelper
  attr_accessor :full_view_array

  def initialize(repositories: [], full_view_array: [], offline: false)
    @repositories = repositories
    @full_view_array = full_view_array
    @offline = offline
    insert_offline_message if @offline # Displaying the offline message if connection is lost
  end

  def prepare_full_view
    display_header
    separator
    display_repositories
    separator
    insert_line(body: "Last updated: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}", level: 0)
  end

  def display
    full_view_array.each do |line|
      puts line
    end
  end

  def display_header
    insert_line(body: "#{main_status_icon(repository: @repositories.first)} #{main_status_text(repository: @repositories.first)}", level: 0, options: { size: 12 })
  end

  def insert_line(body:, level: 0, icon: nil, options: {})
    full_text = "#{'--' * level}"
    full_text += " #{icon}" if icon
    full_text += " #{body}"
    options[:size] = 11 if options[:size].nil?
    full_text += " |" if options.any?
    full_text += " #{options.map { |key, value| "#{key}=#{value}" }.join(' ')}"
    @full_view_array << full_text
  end

  def separator
    insert_line(body: "---", level: 0)
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
      insert_line(body: time_since(updated_at: detail['created_at']), level: 1)
    end
    display_pull_requests(repository: repository)
    display_branches(repository: repository)
  end

  def display_pull_requests(repository:)
    display_prs(prs_data: repository.review_requested_prs, title: 'review requested', icon: '👀', to_review: true)
    display_prs(prs_data: repository.reviewed_prs, icon: '👍', title: 'already reviewed')
    display_prs(prs_data: repository.my_prs, icon: '🤓', title: 'owned open PRs')
  end

  def display_prs(prs_data:, title:, icon: '👍', to_review: false)
    insert_line(body: "#{prs_data.count} #{title.gsub("\n", ' ')}", level: 0, icon: icon)
    prs_data.each do |pr|
      insert_line(body: format_pr(pull_request: pr), level: 1, options: { href: pr.url })
      insert_line(body: pr.head_ref_name, level: 2, icon: '🔗', options: { href: pr.url })
      insert_reviews(pull_request: pr)
      insert_line(body: status_text(pull_request: pr), level: 2, icon: status_icon(status: pr.status_check_rollup_state),
                  options: { color: status_color(pull_request: pr), href: pr.status_check_rollup })
      insert_line(body: mergeable_text(pull_request: pr), level: 2, icon: status_icon(status: pr.mergeable), options: { color: mergeable_color(pull_request: pr) })
      insert_line(body: time_since(updated_at: pr.updated_at), level: 2) if to_review
    end
  end

  def display_branches(repository:)
    insert_line(body: "#{repository.my_branches.count} branches", level: 0, icon: '🌳')
    repository.my_branches.each do |branch|
      insert_line(body: branch, level: 1, icon: '🔗', options: { href: "https://github.com/#{repository.name}/compare/#{branch}?expand=1" })
    end
  end

  def insert_reviews(pull_request:)
    insert_line(body: "no reviews yet", level: 2, icon: '🤷‍♀️') and return if pull_request.reviews.empty?

    pull_request.reviews.group_by { |review| review.author }.each do |login, reviews|
      insert_line(body: "#{reviews.last.state.downcase.capitalize.gsub('_', ' ')} by #{login}", level: 2, icon: review_icon(pr_review: reviews.last),
                  options: { color: review_color(pr_review: reviews.last) })
    end
  end

  def insert_offline_message
    insert_line(body: "Offline mode", level: 0, icon: '⚠️')
  end
end
