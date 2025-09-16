require_relative 'models/repository.rb'

# RepositoriesController
# Service controller to construct `Repository` objects from provided data.
class RepositoriesController
  def initialize(repositories_data:)
    @repositories = repositories_data || []
  end

  def fetch_repositories
    @repositories.map do |repository|
      Repository.new(name: repository['name'], default_branch: repository['default_branch'])
    end
  end
end
