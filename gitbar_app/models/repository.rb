require_relative 'pull_request'
require_relative 'review_request'
require_relative '../services/gh_service'
require_relative '../services/status_checks'

# Repository
# Value object for a GitHub repository with pull requests,
# exposing convenience predicates for ownership and mergeability.
class Repository
  attr_accessor :name, :pull_requests, :url, :status, :status_details, :default_branch, :local_path

  def initialize(repository_data:)
    @name = repository_data['name']
    @default_branch = repository_data['default_branch']
    @local_path = repository_data['local_path']
    @pull_requests = []
    @url = nil
    add_pull_requests
    @url = "https://github.com/#{@name}"
    @status = nil
    @status_details = nil
    current_status
  end

  def add_pull_requests
    json_pull_requests = GhService.new(repo_name: @name).fetch_pull_requests

    json_pull_requests.each do |pr|
      @pull_requests << PullRequest.new(pr_data: pr)
    end
  end

  def review_requested_prs
    @pull_requests.select { |pr| review_requested?(pr.review_requests) }
  end

  def reviewed_prs
    @pull_requests.reject { |pr| review_requested?(pr.review_requests) }
  end

  def my_prs
    @pull_requests.select { |pr| pr.is_mine? }
  end

  def my_branches
    @my_branches ||= GhService.new(repo_name: @name).fetch_branches_not_open_prs
  end

  def review_requested?(review_requests)
    review_requests.any? { |review_request| review_request.author == USERNAME }
  end

  def current_status
    service = GhService.new(repo_name: @name)
    combined = service.fetch_status(branch: @default_branch)
    check_runs = service.fetch_check_runs(branch: @default_branch)

    commit_statuses = combined['statuses'] || []
    check_details = StatusChecks.normalize_check_runs(check_runs['check_runs'] || [])

    # Merge legacy commit statuses and Actions check runs into one detail list.
    @status_details = commit_statuses + check_details
    @status = aggregate_status(combined_state: combined['state'], details: @status_details)
  end

  def aggregate_status(combined_state:, details:)
    states = details.map { |detail| StatusChecks.commit_status_state(detail['state']) }
    # No checks from either system: keep the API's combined state (legacy behavior).
    StatusChecks.aggregate(states) || combined_state
  end

  def simple_name
    @name.split('/').last
  end
end
