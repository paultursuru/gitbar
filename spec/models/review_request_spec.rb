# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe ReviewRequest do
  let(:review_request_data) do
    {
      'login' => 'bob'
    }
  end

  describe '#new' do
    it 'sets author from login' do
      review_request = ReviewRequest.new(review_request_data: review_request_data)
      expect(review_request.author).to eq('bob')
    end
  end
end
