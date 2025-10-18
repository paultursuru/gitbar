# frozen_string_literal: true

require 'json'

# GHService
# Service to interact with the GitHub API.
class GhService
  def initialize(repo_name:)
    @repo_name = repo_name
  end

  def fetch_branches_not_open_prs
    branches_names = fetch_branches_names_for_repo
    branches_names.each do |branch_name|
      output = `#{GH_PATH} api repos/#{@repo_name}/branches/#{branch_name}/prs --jq '.[].number'`
      output.split("\n")
    end
  end

  def fetch_branches_names_for_repo
    owner, repo = @repo_name.split('/', 2)

    output = `#{GH_PATH} api graphql -f owner=#{owner} -f repo=#{repo} -f query='#{graphql_query_for_last_branches}'`
    data = JSON.parse(output)

    nodes = data.dig('data', 'repository', 'refs', 'nodes') || []
    nodes_with_dates = nodes.select do |node|
      target = node['target']
      target && (target['pushedDate'] || target['committedDate']) && target['author']['user']['login'] == USERNAME
    end
    nodes_with_dates.map { |node| node['name'] } | []
  end

  private

  def graphql_query_for_last_branches
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
                }
              }
            }
          }
        }
      }
    GRAPHQL
  end
end
