require_relative './common.rb'

DEFAULT_APP_NAME = "mastodon-cli-sample"
DEFAULT_MASTODON_URL = 'https://mstdn.jp'
FULL_ACCESS_SCOPES = "read write follow"
max_id = 0

Dotenv.load

if !ENV["MASTODON_URL"]
  ENV["MASTODON_URL"] = ask("Instance URL: "){|q| q.default = DEFAULT_MASTODON_URL}
  File.open(".env", "a+") do |f|
    f.write "MASTODON_URL = '#{ENV["MASTODON_URL"]}'\n"
  end
end

scopes = ENV["MASTODON_SCOPES"] || FULL_ACCESS_SCOPES
app_name = ENV["MASTODON_APP_NAME"] || DEFAULT_APP_NAME

if !ENV["MASTODON_CLIENT_ID"] || !ENV["MASTODON_CLIENT_SECRET"]
  client = Mastodon::REST::Client.new(base_url: ENV["MASTODON_URL"])
  app = client.create_app(app_name, "urn:ietf:wg:oauth:2.0:oob", scopes)
  ENV["MASTODON_CLIENT_ID"] = app.client_id
  ENV["MASTODON_CLIENT_SECRET"] = app.client_secret
  File.open(".env", "a+") do |f|
    f.write "MASTODON_CLIENT_ID = '#{ENV["MASTODON_CLIENT_ID"]}'\n"
    f.write "MASTODON_CLIENT_SECRET = '#{ENV["MASTODON_CLIENT_SECRET"]}'\n"
  end
end

if !ENV["MASTODON_ACCESS_TOKEN"]
  client = OAuth2::Client.new(ENV["MASTODON_CLIENT_ID"],
                              ENV["MASTODON_CLIENT_SECRET"],
                              site: ENV["MASTODON_URL"])
  login_id = ask("Your Account: ")
  password = ask("Your Password: "){|q| q.echo = "*"}
  token = client.password.get_token(login_id, password, scope: scopes)
  ENV["MASTODON_ACCESS_TOKEN"] = token.token
  File.open(".env", "a+") do |f|
    f.write "MASTODON_ACCESS_TOKEN = '#{ENV["MASTODON_ACCESS_TOKEN"]}'\n"
  end
end

client = Mastodon::REST::Client.new(base_url: ENV["MASTODON_URL"],
                                    bearer_token: ENV["MASTODON_ACCESS_TOKEN"])

## 投稿する
# message = ARGV[0] || ask("Your Message: ")
# response = client.create_status(message)
# p client.public_timeline()



def get_timeline(*max_id,client)
  responses = client.public_timeline({:max_id => max_id}) unless max_id == 0 
  responses = client.public_timeline() if max_id == 0
  db_array = []
  responses.each do |response|
    # p response
    response_hash = response.to_h
    db_hash = {}
    p response_hash
    exit
    db_hash[:text] = response_hash["content"]
    db_hash[:toot_id] = response_hash["id"]
    db_hash[:toot_date] = response_hash["created_at"]    
    db_hash[:account_id] = response_hash["account"]["id"]    
    db_hash[:user_name] = response_hash["account"]["username"]   
    db_hash[:display_name] = response_hash["account"]["display_name"]  
    db_array << db_hash   
  end
  db_array
end

## とりあえず結果を出力してみる

# ひたすら連打
while TRUE
  id_array = []
  p max_id
  db_data = get_timeline(max_id,client) unless max_id == 0
  db_data = get_timeline(client) if max_id  == 0
  db_data.each do |db|
    id_array << db[:toot_id]
    Toot.find_or_create_by(db)
  end
  max_id = id_array.min
  break if id_array.length == 0
  sleep(1)
end

__END__
公式URL
http://www.rubydoc.info/gems/mastodon-api/Mastodon/REST/Timelines#home_timeline-instance_method

public_timeline → option hash形式
:max_id (Integer)
:since_id (Integer)
:limit (Integer)

qiita
http://qiita.com/takahashim/items/a8c0eb3a75d366cfe87b

