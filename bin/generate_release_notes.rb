#!/usr/bin/env ruby

require 'bundler/setup'
require 'dotenv'
require 'octokit'
require 'yaml'

# load .env vars
Dotenv.load

class GenerateReleaseNotes

  def initialize(repo_name, previous_sha_file, access_token)
    @repo_name = repo_name
    @pull_request_notes = []
    # Grab out previous sha
    @previous_sha_file = previous_sha_file
    @previous_sha_yaml = YAML::load_file(@previous_sha_file)
    set_versions
    # create github api client and grab initial commits
    @client = Octokit::Client.new(access_token: access_token)
    commits = @client.commits(repo_name, 'master')
    @newest_sha = commits.first[:sha]
    # start creating the notes
    scan_commits commits
    # update the notes
    update_release_notes
  end

  # grab out build verion info
  def set_versions
    @git_release_version = `git describe --tags --always --abbrev=0`
    @number_of_commits = `git rev-list master | wc -l | tr -d ' '`
  end

  # add PRs from commits
  def scan_commits(commits)
    commits.each do |commit|
      return true if @previous_sha_yaml['previous-sha'] == commit[:sha]
      match = commit[:commit][:message].match(/pull request #(\d+) from/)
      if match
        pr_num = match.captures[0]
        pr = @client.pull_request @repo_name, pr_num
        if pr[:state] == 'closed'
          @pull_request_notes << "#### ##{pr_num} - #{pr[:title]}\n#{pr[:body]}"
        end
      end
    end
    scan_commits @client.commits_before(@repo_name, DateTime.parse(commits.last[:commit][:author][:date].to_s))
  end

  def update_release_notes
    # new release notes
    release_notes = "### Ello #{@git_release_version} Build #{@number_of_commits} #{Time.now.strftime("%B %-d, %Y")}\n\n"
    release_notes << <<-EOF
    #{@pull_request_notes.count > 0 ? @pull_request_notes.join("\n\n------\n\n") : 'No completed pull requests since last distribution.'}
    #{"\n------------\n"}
    EOF

    if ARGV[0] && ARGV[0].split(',').include?("testers")
      # prepend new contents into release-notes
      old = File.open('release-notes.md', 'a')
      new = File.open('release-notes.new.md', 'w')
      File.open(new, 'w') { |f|
        f.puts release_notes
        f.puts File.read(old)
      }
      File.rename(new, old)

      # add release_notes to crashlytics-release-notes
      File.open('Build/crashlytics-release-notes.md', 'w') { |f| f.write release_notes }

      # update the latest commit from here
      @previous_sha_yaml["previous-sha"] = @newest_sha
      File.open(@previous_sha_file, 'w') {|f| f.write @previous_sha_yaml.to_yaml }
    else
      puts release_notes
    end
  end

end

GenerateReleaseNotes.new('ello/ello-ios', 'bin/previous-sha.yml', ENV['GITHUB_API_TOKEN'])

