from gensim.models import word2vec

tokyo_politic_file = 'toot.wakati'


# Word2Vecモデル
data = word2vec.LineSentence(tokyo_politic_file)
model = word2vec.Word2Vec(data,size=400,window=10,hs=1,min_count=10,sg=1)
model.save('tokyo_model')
