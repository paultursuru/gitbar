# frozen_string_literal: true

require 'json'

# GHService
# Service to interact with the GitHub API.
class GhService
  def initialize(repo_name:)
    @repo_name = repo_name
  end

  def fetch_pull_requests
    pull_requests = `#{GH_PATH} pr list --repo #{@repo_name} --state open --json title,number,url,reviews,reviewRequests,author,updatedAt,mergeable,statusCheckRollup,headRefName`

    JSON.parse(pull_requests)
  end

  def fetch_status(branch:)
    status = `#{GH_PATH} api repos/#{@repo_name}/commits/#{branch}/status`

    JSON.parse(status)
  end

  def fetch_branches_not_open_prs
    owner, repo = @repo_name.split('/', 2)

    output = `#{GH_PATH} api graphql -f owner=#{owner} -f repo=#{repo} -f query='#{graphql_query_for_last_branches_open}'`
    data = JSON.parse(output)

    nodes = data.dig('data', 'repository', 'refs', 'nodes') || []
    nodes_with_dates = nodes.select do |node|
      target = node['target']
      target && target['committedDate'] && target['author']['user']['login'] == USERNAME && target['associatedPullRequests']['totalCount'].zero?
    end
    nodes_with_dates.map { |node| node['name'] } | []
  end

  private

  def graphql_query_for_last_branches_open
    <<~GRAPHQL
      query($owner: String!, $repo: String!) {
        repository(owner: $owner, name: $repo) {
          refs(refPrefix: "refs/heads/", last: 10) {
            nodes {
              name
              target {
                ... on Commit {
                  committedDate
                  author {
                    user { login }
                  }
                  associatedPullRequests(first: 10, orderBy: {field: UPDATED_AT, direction: DESC}) {
                    totalCount
                    nodes {
                      title
                      state
                      merged
                    }
                  }
                }
              }
            }
          }
        }
      }
    GRAPHQL
  end
end
