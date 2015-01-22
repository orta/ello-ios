#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'pivotal-tracker'
require 'yaml'
require 'rugged'


def what_version
 output = `agvtool what-version -terse`
 output.length > 0 ? output : nil
end

def what_marketing_version
 output = `agvtool what-marketing-version -terse`
 output.scan(/\=(.+)$/).flatten.first
end

config = YAML::load_file('bin/release-notes-config.yml')

# read the previous commit
last_commit = config["previous-commit"]

# open the repo
repo = Rugged::Repository.new('.git')

# read the latest commit from head
latest_commit = repo.head.target.oid

# Parse out story IDs from the current commit
commit_range = "#{last_commit}..#{latest_commit}"
story_ids = `git log --format=%B #{commit_range}`.scan(/\[\#(\d+)\]/).map(&:first)

PivotalTracker::Client.token = "fc826e4f5dd2622f519e09c62f32b982"
PivotalTracker::Client.use_ssl = true
project = PivotalTracker::Project.find("1214202")
stories = story_ids.uniq.map { |story_id| project.stories.find(story_id) }.compact

build_number = what_version
marketing_version = what_marketing_version
testflight_message = "Ello #{marketing_version} Build #{build_number}"

# Append story notes
if stories.size > 0
testflight_message << <<-EOF

Tracker stories:
#{stories.map { |s| "[#{s.id}] #{s.name}" } * "\n"}

EOF
end

puts testflight_message

release_note_message = "###Ello #{marketing_version} Build #{build_number}"

# Append story notes
if stories.size > 0
release_note_message << <<-EOF

####Tracker stories:
#{stories.map { |s| "* [#{s.id}](#{s.url}) #{s.name}" } * "\n"}

EOF
end

commit_notes = `git log --format=%s #{commit_range}`
formatted_commit_notes = %(#{commit_notes}).split(/\n/).map { |s| "* #{s}" } * "\n"

# Append commit notes
release_note_message << <<-EOF
####Commit notes:

#{formatted_commit_notes}

EOF

open('release-notes.md', 'a') { |f|
 f.puts "\n-----------------"
 f.puts "#{release_note_message}"
 f.puts "-----------------\n"
}

config["previous-commit"] = "#{latest_commit}"
File.open('bin/release-notes-config.yml', 'w') {|f| f.write config.to_yaml }

