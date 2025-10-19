require_relative 'pull_request'
require_relative 'review_request'
require_relative '../services/gh_service'

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
    output = `#{GH_PATH} pr list --repo #{@name} --state open --json title,number,url,reviews,reviewRequests,author,updatedAt,mergeable,statusCheckRollup,headRefName`

    json = JSON.parse(output)
    json.each do |pr|
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
    GhService.new(repo_name: @name).fetch_branches_not_open_prs
  end

  def review_requested?(review_requests)
    review_requests.any? { |review_request| review_request.author == USERNAME }
  end

  def current_status
    output = `#{GH_PATH} api repos/#{@name}/commits/#{@default_branch}/status`

    @status = JSON.parse(output)['state']
    @status_details = JSON.parse(output)['statuses']
  end

  def simple_name
    @name.split('/').last
  end
end
