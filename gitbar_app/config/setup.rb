# frozen_string_literal: true

# This class is responsible for managing the initial setup and configuration
# of the Gitbar application. It handles loading settings, ensuring necessary
# configurations are present, and preparing the application environment.
class Setup
  # check weither GH is installed with brew or local
  def self.gh_path
    # which returns "whatever not found" if whatever is not installed.
    gh_cli_path = `which gh`.strip

    # In case "which" does not work, we test two common paths for gh
    if gh_cli_path.empty? || gh_cli_path.match?(/not found/)
      if File.exist?('/opt/homebrew/bin/gh')
        gh_cli_path = '/opt/homebrew/bin/gh'
      elsif File.exist?('/usr/local/bin/gh')
        gh_cli_path = '/usr/local/bin/gh'
      end
    end

    # If gh_cli_path is still empty..
    raise 'GitHub CLI (gh) not found. Please install it to use Gitbar.' if gh_cli_path.empty? || gh_cli_path.match?(/not found/)

    gh_cli_path
  end

  def self.fetch_username
    whoami = `#{GH_PATH} config get user -h github.com`
    whoami.strip
  end

  def self.load_settings
    # Loading repositories list
    settings_path = File.join(__dir__, 'settings.json')
    JSON.parse(File.read(settings_path))
  end

  def self.load_full_view_array
    # Loading the last persisted view in case the connection is lost.
    full_view_path = File.join(__dir__, 'view.json')
    File.write(full_view_path, []) unless File.exist?(full_view_path)
    JSON.parse(File.read(full_view_path))
  end

  def self.check_connection
    # Checking connection - sending only one packet
    ping_to_gh = `ping -c 1 github.com`
    if ping_to_gh.empty? # No connection
      puts '⚠️ No connection to GitHub' # Will be displayed as plugin header
      false
    else # If it is not empty, then the connection is successfull
      true
    end
  end
end
