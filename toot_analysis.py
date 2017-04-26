#coding:utf-8
import pymysql
from janome.tokenizer import Tokenizer
import re
import sys
import os

#接続情報
dbh = pymysql.connect(
         host='localhost',
         user='root',
         password='',
         db='mastdon',
         charset='utf8',
         cursorclass=pymysql.cursors.DictCursor
    )

# 形態素解析
#Tokenizer出力例
# 英国	名詞,固有名詞,地域,国,*,*,英国,エイコク,エイコク
t = Tokenizer()
results = []
r = []
#カーソル
stmt = dbh.cursor()
toot_politic_file = 'toot.wakati'


rows = []

cmd = "touch toot.wakati"
os.system( cmd )


sql = "SELECT * FROM toots"
stmt.execute(sql)
rows = stmt.fetchall()
for row in rows:
    tokens = t.tokenize(row["text"])
    with open(toot_politic_file,'a',encoding='utf-8') as fp:
        for tok in tokens:
            if tok.base_form == "*":
                w = tok.surface
            else:
                w = tok.base_form
            ps = tok.part_of_speech #瀕死情報
            hinsi = ps.split(',')[0]
            if hinsi in ['名詞','形容詞']:
                print(w)
                r.append(w)
        rl = (" ".join(r)).strip()
        fp.write(rl)
        fp.write("\n")
        r = []
        rl = ""



stmt.close();
dbh.close();




