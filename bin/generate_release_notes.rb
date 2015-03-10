#!/usr/bin/env ruby

require 'bundler/setup'
require 'dotenv'
require 'octokit'
require 'yaml'

# load .env vars
Dotenv.load

# grab out build verion info
def build_version
 output = `agvtool what-version -terse`
 output.length > 0 ? output : nil
end

def marketing_version
 output = `agvtool what-marketing-version -terse`
 output.scan(/\=(.+)$/).flatten.first
end

current_notes = ""

# Grab out pull request info within range
repo_name = 'ello/ello-ios'
previous_sha = YAML::load_file('bin/previous-sha.yml')
client = Octokit::Client.new(access_token: ENV['GITHUB_API_TOKEN'])
# These are grabbed from newest to oldest by 30
# TODO: figure out how to get more..
commits = client.commits(repo_name, 'master')
commits.each do |commit|
  break if previous_sha["previous-sha"] == commit[:sha]
  match = commit[:commit][:message].match(/pull request #(\d+) from/)
  if match
    pr_num = match.captures[0]
    pr = client.pull_request(repo_name, pr_num)
    if pr[:state] == 'closed'
      current_notes << "##{pr_num} - #{pr[:title]}"
      current_notes << pr[:body]
      current_notes << "\n\n---\n"
    end
  end
end

# new release notes
release_notes = "### Ello #{marketing_version} Build #{build_version} #{Time.now.strftime("%B %-d, %Y")}\n\n"
release_notes << <<-EOF
#{current_notes.length ? current_notes : 'No completed pull requests since last distribution.'}
#{"\n-----------------\n"}
EOF

# if ARGV[0] && ARGV[0].split(',').include?("testers")
  # prepend new contents into release-notes
  old = File.open('release-notes.md', 'a')
  new = File.open('release-notes.new.md', 'w')
  File.open(new, 'w') { |f|
    f.write release_notes
    f.puts File.read(old)
  }
  File.rename(new, old)

  # add release_notes to crashlytics-release-notes
  File.open('Build/crashlytics-release-notes.md', 'w') { |f| f.write release_notes }

  # update the latest commit from here
  previous_sha["previous-sha"] = "#{commits.first[:sha]}"
  File.open('bin/previous-sha.yml', 'w') {|f| f.write previous_sha.to_yaml }
# end

