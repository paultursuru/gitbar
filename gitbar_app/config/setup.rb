# frozen_string_literal: true

# This class is responsible for managing the initial setup and configuration
# of the Gitbar application. It handles loading settings, ensuring necessary
# configurations are present, and preparing the application environment.
class Setup
  def self.fetch_username
    begin
      whoami = `/opt/homebrew/bin/gh config get user -h github.com`
    rescue StandardError
      whoami = `/usr/local/bin/gh config get user -h github.com`
    end
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
    !ping_to_gh.empty? # If it is not empty, then the connection is successfull
  end
end
