# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe Review do
  let(:review_data) do
    {
      'state' => 'APPROVED',
      'body' => 'Looks good to me',
      'author' => { 'login' => 'alice' }
    }
  end

  describe '#new' do
    it 'sets core attributes' do
      review = Review.new(review_data: review_data)
      expect(review.state).to eq(review_data['state'])
      expect(review.body).to eq(review_data['body'])
      expect(review.author).to eq(review_data['author']['login'])
    end
  end
end
