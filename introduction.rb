#メタプログラミング＝コードを記述するコードを記述すること

#C++などでは実行時に言語要素(変数、クラス、メソッド)を読み込んだりすることはできないが、rubyではできる

#introduction/introspection.rb
#-----
class Greeting
  def initialize(text)
    @text = text
  end
  
  def welcome
    @text
  end
end

my_object = Greeting.new("Hello")

#実行時に言語要素を読み込むことができる(イントロスペクション)
my_object.class   #=> Greeting
my_object.class.instance_methods(false) #=> [:welcome]
my_object.instance_variables #=> [:@text]
#-----

#ボブの目標：映画ファンのためのSNS作成
#オブジェクトをデータベースに永続化する簡単なライブラリをつくってみた
#introduction/orm.rb
#-----
class Entiry
  attr_reader :table, :ident
  
  def initialize(table, ident)
    @table = table
    @ident = ident
    Database.sql "INSERT INTO #{@table} (id) VALUES (#{@ident})"
  end

  def set(cal, val)
    Database.sql "UPDATE #{@table} SET #{col}='#{val}' WHERE id=#{@ident}"
  end

  def get(cal)
    Database.sql("SELECT #{cal} FROM #{@rable} WHERE id=#{@ident}")[0][0]
  end
end
#*上記のSQL部分はあまり良い書き方ではない。
#SQLを生成するライブラリを作る時は必ず静的プレースホルダをつかうこと

#Entityクラスのサブクラスを作って任意のテーブルをマッピング
class Movie < Entity
  def initialize(ident)
    super("movies", ident)
  end

  def title
    get("title")
  end

  def title=(value)
    set("title", value)
  end
  
  def director
    get("director")
  end

  def director=(value)
    set("director", value)
  end
end

#新しいレコードをmoviesテーブルにいれてみる
movie = Movie.new(1)
movie.title = "博士の異常な愛情"
movie.director = "スタンリー・キューブリック"
#-----

#同僚のビルに見せたら、コードが重複しすぎって言われた
#ビル「メタプログラミングを使ってコードを短くすれば解決できると思うよ」

#ActiveRecord使えばよかったんや!

#改良版
#-----
class Movie < ActiveRecord::Base
end

movie = Movie.create
movie.title="博士の異常な愛情"
movie.title    #=> "博士の異常な愛情"
#-----

#ActiveRecordがイントロスペクションを使ってクラス名を調べテーブルをマッピングしている
#アクセサメソッドについても、ActiveRecordがデータベースのスキーマからカラム名を取得して自動的にメソッドを定義している
#言語要素から読み込むだけでなく、書き込みもしている

#ActiveRecord::Baseを継承するだけで実行時にアクセサメソッドが定義される=「コードを記述するコードを記述する」

#メタプログラミングを使うことでrubyと仲良くなれる！
