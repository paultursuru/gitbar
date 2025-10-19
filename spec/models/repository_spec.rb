# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe Repository do
  let(:repository_data) { { 'name' => 'test/test', 'default_branch' => 'main', 'local_path' => '/test' } }

  describe '#new' do
    before do
      fake_service = instance_double(GhService)
      allow(fake_service).to receive(:fetch_pull_requests).and_return([])
      allow(fake_service).to receive(:fetch_status).and_return({ 'state' => 'success', 'statuses' => [] })
      allow(GhService).to receive(:new).and_return(fake_service)
    end

    it 'should create a new repository' do
      repository = Repository.new(repository_data: repository_data)
      expect(repository.name).to eq(repository_data['name'])
      expect(repository.default_branch).to eq(repository_data['default_branch'])
      expect(repository.local_path).to eq(repository_data['local_path'])
      expect(repository.pull_requests).to be_empty
      expect(repository.url).to eq("https://github.com/#{repository_data['name']}")
      expect(repository.status).to eq('success')
      expect(repository.status_details).to eq([])
    end
  end
end
