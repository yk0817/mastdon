#!/usr/bin/env ruby
require 'bundler/setup'
Bundler.require(:default)

require 'mastodon'
require 'highline/import'
require 'oauth2'
require 'dotenv'
require 'pp'
require 'active_record'
require 'open-uri'
require 'nokogiri'

ActiveRecord::Base.logger = Logger.new(STDOUT)

dbname = File.dirname(File.expand_path(__FILE__)).split('/').last

ActiveRecord::Base.establish_connection(
      :adapter  => 'mysql2',
      :charset => 'utf8mb4',
      :encoding => 'utf8mb4',
      :collation => 'utf8mb4_general_ci',
      :database => dbname,
      :host     => 'localhost',
      :username => 'root',
      :password => ''
)

# DBのタイムゾーン設定
Time.zone_default =  Time.find_zone! 'Tokyo' # config.time_zone
ActiveRecord::Base.default_timezone = :local # config.active_record.default_timezone

class Toot < ActiveRecord::Base
end

class Crawl < ActiveRecord::Base
end

class CrawlState < ActiveRecord::Base
end