require_relative './common.rb'

class MatCrawl
  def crawl(url)
    charset = nil
    html = open(url) do |f|
      charset = f.charset
      f.read 
    end
    Nokogiri::HTML.parse(html, nil, charset)
  end
  def parse(nokogiri_parse)
    doc = nokogiri_parse    
    doc
  end
  
  def next_page?(nokogiri_parse)
    # 次のページ
    if nokogiri_parse.at(".next")
      next_url = nokogiri_parse.css(".next")[0]["href"]
    else
      next_url = false
    end
    return next_url
  end
  
end

crawl = MatCrawl.new

url = "https://mstdn.jp/@mazzo"

while TRUE
  nokogiri_parse = crawl.crawl(url)
  # array = []
      
  nokogiri_parse.css(".entry").each do |parse|
    hash = {}
    hash[:toot_id] = parse.css(".status__meta > .u-uid")[0].attributes["href"].value.match(/.+\/(\d+)$/).captures[0]
    hash[:toot_username] = parse.css(".display-name > span").text
    hash[:toot_display_name] = parse.css(".display-name > strong").text
    hash[:toot_reblogged] = 1 if parse.at(".fa-retweet") #ブーストは1　ブーストじゃない→0
    hash[:toot_display_name] = parse.css(".display-name").to_html
    hash[:toot_link_text] = parse.css(".status__attachments__inner").to_html if parse.at(".status__attachments__inner")
    hash[:toot_date] =  Time.parse(parse.css("time")[0].attributes["datetime"].value) #データとして保存用
    hash[:toot_text] = parse.css("div.e-content").to_html #テキスト本文 面倒なんでタグごとぶっこむ
    # p hash
    # array << hash
    Toot.create(hash)
  end
  sleep(1)
  next_url = crawl.next_page?(nokogiri_parse)
  break unless next_url
  url = next_url
end