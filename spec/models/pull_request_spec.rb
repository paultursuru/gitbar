# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe PullRequest do
  let(:pull_request_data) do
    {
      'title' => 'test',
      'number' => 1,
      'url' => 'https://github.com/test/test',
      'statusCheckRollup' => [{ '__typename' => 'StatusContext', 'targetUrl' => 'https://github.com/test/test', 'state' => 'SUCCESS', 'context' => 'test' }],
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
      expect(pull_request.status_check_rollup_state).to eq('SUCCESS')
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

  describe '#new with GitHub Actions check runs in the rollup' do
    before do
      allow(Review).to receive(:generate_reviews).and_return([])
      allow(ReviewRequest).to receive(:generate_review_requests).and_return([])
    end

    def pr_with(rollup)
      PullRequest.new(pr_data: pull_request_data.merge('statusCheckRollup' => rollup))
    end

    it 'aggregates CheckRun entries (which have status/conclusion, not state)' do
      pr = pr_with([
                     { '__typename' => 'CheckRun', 'name' => 'Test', 'status' => 'completed', 'conclusion' => 'success', 'detailsUrl' => 'https://gh/test' },
                     { '__typename' => 'CheckRun', 'name' => 'Deploy', 'status' => 'completed', 'conclusion' => 'success', 'detailsUrl' => 'https://gh/deploy' }
                   ])
      expect(pr.status_check_rollup_state).to eq('SUCCESS')
    end

    it 'does not treat neutral/skipped conclusions as a failure' do
      pr = pr_with([
                     { '__typename' => 'CheckRun', 'name' => 'Lint', 'status' => 'completed', 'conclusion' => 'success', 'detailsUrl' => 'https://gh/lint' },
                     { '__typename' => 'CheckRun', 'name' => 'Optional', 'status' => 'completed', 'conclusion' => 'skipped', 'detailsUrl' => 'https://gh/opt' },
                     { '__typename' => 'CheckRun', 'name' => 'Note', 'status' => 'completed', 'conclusion' => 'neutral', 'detailsUrl' => 'https://gh/note' }
                   ])
      expect(pr.status_check_rollup_state).to eq('SUCCESS')
    end

    it 'reports pending while a run is in progress and points to it' do
      pr = pr_with([
                     { '__typename' => 'CheckRun', 'name' => 'Test', 'status' => 'completed', 'conclusion' => 'success', 'detailsUrl' => 'https://gh/test' },
                     { '__typename' => 'CheckRun', 'name' => 'Deploy', 'status' => 'in_progress', 'conclusion' => nil, 'detailsUrl' => 'https://gh/deploy' }
                   ])
      expect(pr.status_check_rollup_state).to eq('PENDING')
      expect(pr.status_check_rollup_context).to eq('Deploy')
      expect(pr.status_check_rollup).to eq('https://gh/deploy')
    end

    it 'reports failure and points to the failing run when mixing systems' do
      pr = pr_with([
                     { '__typename' => 'StatusContext', 'context' => 'ci/external', 'state' => 'SUCCESS', 'targetUrl' => 'https://ext/ok' },
                     { '__typename' => 'CheckRun', 'name' => 'Deploy', 'status' => 'completed', 'conclusion' => 'failure', 'detailsUrl' => 'https://gh/deploy' }
                   ])
      expect(pr.status_check_rollup_state).to eq('FAILURE')
      expect(pr.status_check_rollup_context).to eq('Deploy')
      expect(pr.status_check_rollup).to eq('https://gh/deploy')
    end
  end
end
