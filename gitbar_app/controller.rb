require_relative 'models/repository.rb'

# Controller
# Service controller to construct `Repository` objects from provided data.
class Controller
  def initialize(repositories_data:)
    @repositories_data = repositories_data || []
  end

  # Fetching repositories from the data
  def fetch_repositories
    @repositories_data.map do |repository_data|
      Repository.new(repository_data: repository_data)
    end
  end

  # Storing the whole created view inside view.json, in case connection is lost
  def persist_view(view:)
    path = File.join(__dir__, 'config', 'view.json')
    File.write(path, view.full_view_array.to_json)
  end
end
