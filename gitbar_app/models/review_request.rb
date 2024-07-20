class ReviewRequest
  attr_reader :author

  def initialize(review_request_data:)
    @author = review_request_data.dig('login')
  end
end