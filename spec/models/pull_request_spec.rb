# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe PullRequest do
  let(:pull_request_data) do
    {
      'title' => 'test',
      'number' => 1,
      'url' => 'https://github.com/test/test',
      'statusCheckRollup' => [{ 'targetUrl' => 'https://github.com/test/test', 'state' => 'success', 'context' => 'test' }],
      'author' => { 'login' => 'test' },
      'updatedAt' => '2021-01-01',
      'mergeable' => 'MERGEABLE',
      'reviews' => [],
      'reviewRequests' => []
    }
  end

  describe '#new' do
    before do
      allow(Review).to receive(:generate_reviews).and_return([])
      allow(ReviewRequest).to receive(:generate_review_requests).and_return([])
    end

    it 'should create a new pull request' do
      pull_request = PullRequest.new(pr_data: pull_request_data)
      expect(pull_request.title).to eq(pull_request_data['title'])
      expect(pull_request.number).to eq(pull_request_data['number'])
      expect(pull_request.url).to eq(pull_request_data['url'])
      expect(pull_request.status_check_rollup).to eq(pull_request_data['statusCheckRollup'][0]['targetUrl'])
      expect(pull_request.status_check_rollup_state).to eq(pull_request_data['statusCheckRollup'][0]['state'])
      expect(pull_request.status_check_rollup_context).to eq(pull_request_data['statusCheckRollup'][0]['context'])
      expect(pull_request.author).to eq(pull_request_data['author']['login'])
      expect(pull_request.updated_at).to eq(pull_request_data['updatedAt'])
      expect(pull_request.mergeable).to eq(pull_request_data['mergeable'])
      expect(pull_request.reviews).to be_empty
      expect(pull_request.review_requests).to be_empty
      expect(pull_request.is_mine?).to eq(pull_request_data['author']['login'] == USERNAME)
      expect(pull_request.can_be_merged?).to be_falsey
    end
  end
end
