require_relative 'review'
require_relative '../services/status_checks'

# PullRequest
# Value object for a GitHub pull request with reviews and review requests,
# exposing convenience predicates for ownership and mergeability.
class PullRequest
  attr_accessor :title, :number, :url, :status_check_rollup, :status_check_rollup_state, :status_check_rollup_context, :author, :updated_at, :mergeable, :reviews, :review_requests, :head_ref_name

  def initialize(pr_data:)
    @reviews = []
    @review_requests = []
    set_pr_with(pr_data: pr_data)
    generate_reviews(reviews_data: pr_data.dig('reviews'))
    generate_review_requests(review_requests_data: pr_data.dig('reviewRequests'))
  end

  def generate_reviews(reviews_data:)
    return if reviews_data.empty?

    reviews_data.each { |review| @reviews << Review.new(review_data: review) }
  end

  def generate_review_requests(review_requests_data:)
    return if review_requests_data.empty?

    review_requests_data.each { |review_request| @review_requests << ReviewRequest.new(review_request_data: review_request) }
  end

  def is_mine?
    @author == USERNAME
  end

  def can_be_merged?
    return false unless @mergeable == 'MERGEABLE' && @reviews.any?

    @reviews.group_by { |review| review.author }.each do |_login, reviews|
      return false if reviews.last.state == 'CHANGES_REQUESTED'

      return reviews.last.state == 'APPROVED'
    end
    nil
  end

  def set_pr_with(pr_data:)
    @title = pr_data.dig('title').gsub('|', ' ')
    @number = pr_data.dig('number')
    @url = pr_data.dig('url')
    set_status_check_rollup(rollup_data: pr_data.dig('statusCheckRollup'))
    @author = pr_data.dig('author', 'login')
    @updated_at = pr_data.dig('updatedAt')
    @mergeable = pr_data.dig('mergeable')
    @head_ref_name = pr_data.dig('headRefName')
  end

  # statusCheckRollup is a list mixing StatusContext (legacy commit statuses)
  # and CheckRun (GitHub Actions) entries. We aggregate them into one state and
  # surface a representative check (a failing/pending one first) for the link.
  def set_status_check_rollup(rollup_data:)
    checks = (rollup_data || []).map { |check| normalize_rollup_check(check) }
    return if checks.empty?

    representative = representative_check(checks)
    @status_check_rollup_state = StatusChecks.aggregate(checks.map { |check| check[:state] })&.upcase
    @status_check_rollup_context = representative[:context]
    @status_check_rollup = representative[:url]
  end

  # Surface the most actionable check for the displayed link/label:
  # a failing one first, then a pending one, else the first.
  def representative_check(checks)
    checks.find { |check| check[:state] == 'failure' } ||
      checks.find { |check| check[:state] == 'pending' } ||
      checks.first
  end

  def normalize_rollup_check(check)
    return check_run_rollup(check) if check['__typename'] == 'CheckRun' || check.key?('conclusion')

    {
      state: StatusChecks.commit_status_state(check['state']),
      context: check['context'],
      url: check['targetUrl']
    }
  end

  def check_run_rollup(check)
    {
      state: StatusChecks.check_run_state(status: check['status'], conclusion: check['conclusion']),
      context: check['name'] || check['workflowName'],
      url: check['detailsUrl']
    }
  end
end
