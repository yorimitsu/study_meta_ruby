## 第1章：オブジェクトモデル
## 1.2：オープンクラス

# ビルとボブはBookwormというアプリをリファクタリングをすることに

# アルファベットとスペースを残して特殊文字を削除する
# object_model/alphanumeric.rb
#---
def to_alphanumeric(s)
  s.gsub /[^\w\s]/, ''
end
#---
# ユニットテスト
#---
require 'test/unit'

class ToAlphanumericTest < Test::Unit::TestCase
  def test_strips_non_alphanumeric_characters
    assert_equal '3 the Magic Number', to_alphanumeric('#3, the *Magic, Number*?')
  end
end
#---

# ビル「文字列自身が変換したほうがオブジェクト指向的(ﾄﾞﾔｯ」

# 改良版
#---
class String            # Stringクラスをオープン
  def to_alphanumeric
    gsub /[^\w\s]/, ''
  end
end
#---
# ユニットテスト
#---
require 'test/unit'

class StringExtensionsTest < Test::Unit::TestCase
  def test_strips_non_alphanumeric_characters
    # Stringクラスに追加したので、文字列から呼べるようになった
    assert_equal '3 the Magic Number', '#3, the *Magic, Number*?'.to_alphanumeric  
  end
end
#---

# *標準クラスには大切なメソッドが存在しているため、
# クラスオープンによってメソッドを追加するかどうかは慎重に判断すべき。
# オープンクラス以外の手法については別で解説。

## 1.2.1：クラス定義の中身

# rubyではクラス定義のコードもその他のコードも違いはなく、クラス定義の中に好きなコードを配置できる

#---
3.times do
  class C
    puts "Hello"
  end
end

#=> Hello
#   Hello
#   Hello

#---

# クラス内のコードが3回実行されているが、クラスが3つ定義されたわけではない。

#---
class D               # => まだクラスDは存在していない
  def x; 'x'; end     # => ここに入った時にクラスDが定義される
end

class D               # => すでに上でクラスDが定義されているので、再オープンになる
  def y; 'y'; end     # => 既存のクラスであるクラスDにy()メソッドを追加
end

obj = D.new
obj.x        # => "x"
obj.y        # => "y"
#---

# つまりクラスCのコードは、クラスCが3回定義されているのではなく、
# 1回目に定義された後はただ再オープンされているだけ。

# rubyのclassキーワードは、クラス宣言というよりもスコープ演算子のようなもの。

# 既存のクラスを再オープンして修正する技術=オープンクラス

# オープンクラスの例
# Monye Gme:金額や通貨のユーティリティ

#---
# 99ドル99セント
cents = 9999
# Moneyオブジェクトの生成
bargain_price = Money.new(cents)

# 数値 => Moneyオブジェクト でもoK
standard_price = 100.to_money
#---

# (/･ω･)/「 Numericは標準クラスなのに、Numeric#to_moneyってどこから来ｔ…( ﾟдﾟ)ﾊｯ!、」

# ライブラリではオープンクラスがよく使われている
# gems/money-2.1.3/lib/money/core_extensions.rb
#---
class Numeric
  def to_money
    Money.new(self * 100)
  end
end
#---

## 1.2.2：オープンクラスの問題点

# Bookwormのリファクタリングにもどる

# object_model/replace.rb
# 配列の要素を置換するメソッド
#---
def replace(array, from, to)
  array.each_with_index do |e, i|
    array[i] = to if e == from
  end
end
#---
# ユニットテスト
#---
def test_replace
  book_topics = ['html', 'jave', 'css']
  replace(book_topics, 'java', 'ruby')
  expected = ['html', 'ruby', 'css']
  assert_equal expected, book_topics
end
#---

# (ビルは反射神経が鈍いので素早くキーボードを奪う)
# 「ここでオープンクラス使ったらいいんや！」

# リファクタリング後
#---
class Array
  def replace(from, to)
    each_with_index do |e, i|
      self[i] = to if e == from
    end
  end
end
#---
# ユニットテスト
#---
def test_replace
  book_topics = ['html', 'jave', 'css']
  book_topics.replace('java', 'ruby')
  expected = ['html', 'ruby', 'css']
  assert_equal expected, book_topics
end
#---

# 上記のテストは失敗する。

#幺ク 亡月 |　 十　||
#小巴 三Ｅ Ｌﾉ ﾉ二 oo
#　　　　　＿＿_
#　　＿＿／　 ／
#　／　　　　 ￣￣＼
#`/　　　　　　 ＜￣
#/　　　　　　　　ヽ
#ﾚ　|＼∧　　　　＼|
#|　|◎)=Ｖ| /＼ Ｎ
#|∧|￣ .. |/　∧|
#`ヽ　 r＝、　/イ
#　ﾚ＼ ﾋ二｣ ／Ｖ
#　/／i`ーイＶ(＼(ヽ､
#　　/|＿ ／￣|＼ヽ||
#　_/[[o／　 (＼｜|||
#／/// /　／￣> `　ノ
#`/｜ /　/　 (　 ／ヽ
#｜｜/　｜　 ｜ ｜　|

# 1.2.3：猿マネとモンキーパッチ
