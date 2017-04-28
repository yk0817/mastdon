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
  
  
  def next?
    #code
  end
end

crawl = MatCrawl.new

while TRUE
  url = "https://mstdn.jp/@mazzo"
  nokogiri_parse = crawl.crawl(url)
  array = []
  # next_url_param = 
  nokogiri_parse.css(".entry").each do |parse|
    hash = {}
    hash[:boost] = parse.css(".entry-reblog") if parse.at(".entry-reblog")
    hash[:name] = parse.css(".display-name").to_html
    hash[:toot_date] = parse.css(".status__relative-time")[0].attributes["title"].value #トゥート日時
    hash[:text] = parse.css("div.e-content").to_html #テキスト本文 面倒なんでタグごとぶっこむ
    print(hash)
    array << hash
  end
  sleep(1)
end