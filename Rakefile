require 'dotenv'
require 'dotenv/tasks'
require 'json'
require './bin/generate_release_notes'

Dotenv.load

namespace :generate do

  desc 'Generates strings file'
  task :strings do
    sh "find Sources -name '*.swift' | xargs genstrings -o ."
  end

  desc 'Generates release notes for devs'
  task :release_notes_devs do
    generate_release_notes('ios-devs')
  end

  desc 'Generates release notes for all testers'
  task :release_notes do
    generate_release_notes('ios-devs,testers')
  end

  def generate_release_notes(list, env = 'PROD')
    ["GITHUB_API_TOKEN", "#{env}_CLIENT_KEY", "#{env}_CLIENT_SECRET", "#{env}_DOMAIN", "#{env}_HTTP_PROTOCOL", 'INVITE_FRIENDS_SALT', 'SEGMENT_KEY'].each do |env_var|
      unless ENV[env_var]
        puts "You must set a '#{env_var}' in your .env file to distribute. You can see examples/defaults in the .env.example file."
        return
      end
    end

    generator = GenerateReleaseNotes.new('ello/ello-ios', 'bin/previous-sha.yml', ENV['GITHUB_API_TOKEN'], list)
    generator.create_release_notes
  end

  desc 'Sets cocoapods-keys for the app pointed at a local development server.'
  task :local_keys do
    has_key = set_key('ClientKey', 'LOCAL_CLIENT_KEY')
    has_key = set_key('ClientSecret', 'LOCAL_CLIENT_SECRET') if has_key
    has_key = set_key('Domain', 'LOCAL_DOMAIN') if has_key
    has_key = set_key('HttpProtocol', 'LOCAL_HTTP_PROTOCOL') if has_key
    has_key = set_key('Salt', 'INVITE_FRIENDS_SALT') if has_key
    sh "bundle exec pod install" if has_key
  end

  desc 'Sets cocoapods-keys for the app pointed at the staging server.'
  task :staging_keys do
    has_key = set_key('ClientKey', 'STAGING_CLIENT_KEY')
    has_key = set_key('ClientSecret', 'STAGING_CLIENT_SECRET') if has_key
    has_key = set_key('Domain', 'STAGING_DOMAIN') if has_key
    has_key = set_key('HttpProtocol', 'STAGING_HTTP_PROTOCOL') if has_key
    has_key = set_key('Salt', 'INVITE_FRIENDS_SALT') if has_key
    has_key = set_key('CrashlyticsKey', 'CRASHLYTICS_KEY') if has_key
    has_key = set_key('SegmentKey', 'SEGMENT_KEY') if has_key
    sh "bundle exec pod install" if has_key
  end

  desc 'Sets cocoapods-keys for the app pointed at the production server.'
  task :prod_keys do
    has_key = set_key('ClientKey', 'PROD_CLIENT_KEY')
    has_key = set_key('ClientSecret', 'PROD_CLIENT_SECRET') if has_key
    has_key = set_key('Domain', 'PROD_DOMAIN') if has_key
    has_key = set_key('HttpProtocol', 'PROD_HTTP_PROTOCOL') if has_key
    has_key = set_key('Salt', 'INVITE_FRIENDS_SALT') if has_key
    has_key = set_key('CrashlyticsKey', 'CRASHLYTICS_KEY') if has_key
    sh "bundle exec pod install" if has_key
  end

  desc 'Sets cocoapods-keys for the app pointed at the production server.'
  task :local_keys do
    has_key = set_key('ClientKey', 'LOCAL_CLIENT_KEY')
    has_key = set_key('ClientSecret', 'LOCAL_CLIENT_SECRET') if has_key
    has_key = set_key('Domain', 'LOCAL_DOMAIN') if has_key
    has_key = set_key('Salt', 'INVITE_FRIENDS_SALT') if has_key
    has_key = set_key('CrashlyticsKey', 'CRASHLYTICS_KEY') if has_key
    has_key = set_key('SegmentKey', 'SEGMENT_KEY') if has_key
    sh "bundle exec pod install" if has_key
  end

  def set_key(key, env_var)
    return false unless check_env(env_var)
    sh "bundle exec pod keys set #{key} #{ENV[env_var]} Ello"
    return true
  end

  def check_env(env_var)
    return true if ENV[env_var]
    puts "You must have #{env_var} defined in your .env file to complete this task."
    return false
  end

  desc 'Pull down latest simulated responses from staging'
  task :responses do
    return false unless check_env('GITHUB_API_TOKEN') && check_env('STAGING_HTTP_PROTOCOL') && check_env('STAGING_DOMAIN')
    index = `curl -H 'Authorization: token #{ENV['GITHUB_API_TOKEN']}' 'https://raw.githubusercontent.com/ello/ello/master/docs/api/index.json'`
    json = JSON.parse(index)
    json["resources"].each do |resource|
      resource['examples'].each do |example|
        link = example['link']
        filename_arr = link.split('/')
        if filename_arr.length > 1
          filename = "#{filename_arr.first}_#{filename_arr.last}".gsub('-', '')
          filename += '.json' unless filename.match(/\.json$/)
          write_json(link, filename)
        end
      end
    end
    sh 'git ls-files --others --exclude-standard'
    puts 'Don\'t forget to add untracked resource files to Xcode!!!!!!!!!!!!!!!'
  end

  def write_json(path, filename = nil)
    puts "Getting file: #{path} for filename: #{filename}"
    path = "#{ENV['STAGING_HTTP_PROTOCOL']}://#{ENV['STAGING_DOMAIN']}/api/docs/simulate/#{path}"
    pretty_json = `curl '#{path}' | python -m json.tool`
    File.open("Resources/StubbedResponses/#{filename}", 'w') {|f| f.write pretty_json }
  end

end
