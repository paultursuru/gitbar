require 'json'
require_relative 'pull_request'
require_relative 'review_request'

class Repository
  attr_accessor :name, :pull_requests, :url, :status, :status_details, :default_branch

  def initialize(name:, default_branch:)
    @name = name
    @default_branch = default_branch
    @pull_requests = []
    @url = nil
    add_pull_requests
    @url = "https://github.com/#{@name}"
    @status = nil
    @status_details = nil
    get_status
  end

  def add_pull_requests
    # Try to use the homebrew version of gh,
    # if it's not available, use the macOS version.
    begin
      output = `/opt/homebrew/bin/gh pr list --repo #{@name} --state open --json title,number,url,reviews,reviewRequests,author,updatedAt,mergeable,statusCheckRollup`
    rescue
      output = `/usr/local/bin/gh pr list --repo #{@name} --state open --json title,number,url,reviews,reviewRequests,author,updatedAt,mergeable,statusCheckRollup`
    end
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

  def review_requested?(review_requests)
    review_requests.any? { |review_request| review_request.author == USERNAME }
  end

  def get_status
    begin
      output = `/opt/homebrew/bin/gh api repos/#{@name}/commits/#{@default_branch}/status`
    rescue
      output = `/usr/local/bin/gh api repos/#{@name}/commits/#{@default_branch}/status`
    end
    @status = JSON.parse(output)['state']
    @status_details = JSON.parse(output)['statuses']
  end
end
