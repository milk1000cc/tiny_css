require File.dirname(__FILE__) + '/../lib/tiny_css'
include TinyCss

describe OrderedHash, '未定義のキーが指定されたとき' do
  before do
    @oh = OrderedHash.new
  end

  it 'は、OrderedHash のインスタンスが得られること' do
    @oh[:a].should be_instance_of(OrderedHash)

  end

  it 'は、keys に そのキーが文字列で追加されること' do
    @oh[:a][:b] = 3
    @oh.keys.last.should == 'a'
  end
end

describe OrderedHash, '代入・参照操作について' do
  before do
    @oh1, @oh2 = OrderedHash.new, OrderedHash.new
    @oh1[:a] = 3
    @oh2['b'] = 4
  end

  it 'は、キーから値が取り出せること' do
    @oh1[:a].should == 3
    @oh2['b'].should == 4
  end

  it 'は、キーがシンボルでも文字列でも同じ値を指すこと' do
    @oh1[:a.to_s].should == @oh1[:a]
    @oh2['b'.to_sym].should == @oh2['b']
  end

  it 'は、キーが文字列に変換されていること' do
    @oh1.keys.should_not include(:a)
    @oh1.keys.should include('a')
    @oh2.keys.should_not include(:b)
    @oh2.keys.should include('b')
  end

  it 'は、きちんと上書き処理がされること' do
    @oh1['a'] = 4
    @oh1['a'].should == 4
  end
end

describe OrderedHash, '#dup について' do
  before do
    @oh = OrderedHash.new
    @dup = @oh.dup
  end

  it 'は、self と 戻り値 の object_id が相違なること' do
    @oh.object_id.should_not == @dup.object_id
  end

  it 'は、self.keys と 戻り値.keys の object_id が相違なること' do
    @oh.keys.object_id.should_not == @dup.keys.object_id
  end
end

describe OrderedHash, '#each について' do
  before do
    @oh1, @oh2 = OrderedHash.new, OrderedHash.new
    @keys1, @keys2 = [], []
    @values1, @values2 = [], []

    @oh1['1'] = 'one'
    @oh1['2'] = 'two'
    @oh1['3'] = 'three'
    @oh2['2'] = 'two'
    @oh2['1'] = 'one'
    @oh2['3'] = 'three'

    @result1 = @oh1.each { |k, v|
      @keys1 << k
      @values1 << v
    }

    @result2 = @oh2.each { |k, v|
      @keys2 << k
      @values2 << v
    }
  end

  it 'は、代入順に要素が処理されること' do
    @keys1.should == ['1', '2', '3']
    @keys2.should == ['2', '1', '3']
    @values1.should == ['one', 'two', 'three']
    @values2.should == ['two', 'one', 'three']
  end

  it 'は、self を返すこと' do
    @result1.should == @oh1
    @result2.should == @oh2
  end
end

describe OrderedHash, '#inspect について' do
  before do
    oh1, oh2 = OrderedHash.new, OrderedHash.new
    oh1['1'] = 'one'
    oh1['2'] = 'two'
    oh1['3'] = 'three'
    oh2['2'] = 'two'
    oh2['1'] = 'one'
    oh2['3'] = 'three'
    @inspect1, @inspect2 = oh1.inspect, oh2.inspect
  end

  it 'は、{#{k.inspect}=>#{v.inspect}, ...} を返すこと' do
    @inspect1.should ==
      '{' +
      "#{ '1'.inspect }=>#{ 'one'.inspect }, " +
      "#{ '2'.inspect }=>#{ 'two'.inspect }, " +
      "#{ '3'.inspect }=>#{ 'three'.inspect }" +
      '}'
    @inspect2.should ==
      '{' +
      "#{ '2'.inspect }=>#{ 'two'.inspect }, " +
      "#{ '1'.inspect }=>#{ 'one'.inspect }, " +
      "#{ '3'.inspect }=>#{ 'three'.inspect }" +
      '}'
  end
end

