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
  array = []
      
  nokogiri_parse.css(".entry").each do |parse|
    hash = {}
    hash[:boost] = parse.css(".entry-reblog") if parse.at(".entry-reblog")
    hash[:name] = parse.css(".display-name").to_html
    hash[:toot_link] = parse.css(".status__relative-time")[0].attributes["href"].value if parse.at(".status__relative-time")
    hash[:toot_date] = parse.css(".status__relative-time")[0].attributes["title"].value #トゥート日時
    hash[:data_date] =  parse.css("time")[0].attributes["datetime"].value #データとして保存用
    hash[:text] = parse.css("div.e-content").to_html #テキスト本文 面倒なんでタグごとぶっこむ
    array << hash
  end
  sleep(1)
  next_url = crawl.next_page?(nokogiri_parse)
  break unless next_url
  url = next_url
end