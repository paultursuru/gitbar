# Review
# Value object wrapping a PR review (state, body, author).
class Review
  attr_accessor :state, :body, :author

  def initialize(review_data:)
    @state = review_data['state']
    @body = review_data['body']
    @author = review_data['author']['login']
  end
end
