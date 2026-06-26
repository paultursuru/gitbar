# frozen_string_literal: true

require_relative 'models/repository'

# Controller
# Service controller to construct `Repository` objects from provided data.
class Controller
  def initialize(repositories_data:)
    @repositories_data = repositories_data || []
  end

  # Fetching repositories from the data.
  # Each repository triggers several independent `gh` calls (network/IO bound),
  # so we build them in parallel threads. Ruby releases the GIL while waiting on
  # the subprocess, giving a near-linear speedup with the number of repos.
  def fetch_repositories
    @repositories_data.map do |repository_data|
      Thread.new { Repository.new(repository_data: repository_data) }
    end.map(&:value)
  end

  # Storing the whole created view inside view.json, in case connection is lost
  def persist_view(view:)
    path = File.join(__dir__, 'config', 'view.json')
    File.write(path, view.full_view_array.to_json)
  end
end
