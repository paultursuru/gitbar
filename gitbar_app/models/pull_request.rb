require_relative 'review'

class PullRequest
  attr_accessor :title, :number, :url, :status_check_rollup, :status_check_rollup_state, :status_check_rollup_context, :author, :updated_at, :mergeable, :reviews, :review_requests

  def initialize(pr_data:)
    @title = pr_data.dig('title')
    @number = pr_data.dig('number')
    @url = pr_data.dig('url')
    @status_check_rollup = pr_data.dig('statusCheckRollup', 0, 'targetUrl')
    @status_check_rollup_state = pr_data.dig('statusCheckRollup', 0, 'state')
    @status_check_rollup_context = pr_data.dig('statusCheckRollup', 0, 'context')
    @author = pr_data.dig('author', 'login')
    @updated_at = pr_data.dig('updatedAt')
    @mergeable = pr_data.dig('mergeable')
    @reviews = []
    @review_requests = []
    generate_reviews(reviews_data: pr_data.dig('reviews'))
    generate_review_requests(review_requests_data: pr_data.dig('reviewRequests'))
  end

  def generate_reviews(reviews_data:)
    reviews_data.each { |review| @reviews << Review.new(review_data: review) }
  end

  def generate_review_requests(review_requests_data:)
    review_requests_data.each { |review_request| @review_requests << ReviewRequest.new(review_request_data: review_request) }
  end

  def is_mine?
    @author == USERNAME
  end

  def can_be_merged?
    return false unless @mergeable == 'MERGEABLE' && @reviews.any?
  
    @reviews.group_by { |review| review.author }.each do |login, reviews|
      return false if reviews.last.state == 'CHANGES_REQUESTED'
  
      return reviews.last.state == 'APPROVED'
    end
    nil
  end
end