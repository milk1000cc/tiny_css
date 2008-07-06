require File.dirname(__FILE__) + '/../lib/tiny_css'
include TinyCss

describe Base, 'CSS 文字列を指定してパースするとき' do
  before do
    @css1 = TinyCss.new.read_string('h3 { color: red; }')
    @css2 = TinyCss.new.read_string('h1, p { color: red }')
    @css3 = TinyCss.new.read_string("h3 { color: red; \n /*z-index: 4;*/\n" +
                                    "background: blue }")
    @css4 = TinyCss.new.read_string('h3,   div   .foo { color: red; ' +
                                    'background: blue },div{color:red;}')
    @selectors2 = ['h1', 'p']
  end

  it 'は、self を返すこと' do
    @css1.should be_instance_of(Base)
    @css2.should be_instance_of(Base)
    @css3.should be_instance_of(Base)
    @css4.should be_instance_of(Base)
  end

  it 'は、style[セレクタ][プロパティ] で値が取り出せること' do
    @css1.style['h3']['color'].should == 'red'
    @css2.style['h1']['color'].should == 'red'
    @css2.style['p']['color'].should == 'red'
    @css3.style['h3']['color'].should == 'red'
    @css3.style['h3']['background'].should == 'blue'
    @css4.style['h3']['color'].should == 'red'
    @css4.style['h3']['background'].should == 'blue'
    @css4.style['div']['color'].should == 'red'
  end

  it 'は、セレクタ文字列中のホワイトスペースが半角 1 スペースに変換されていること' do
    @css4.style['div .foo']['color'].should == 'red'
    @css4.style['div .foo']['background'].should == 'blue'
  end

  it 'は、コメント内のスタイルが反映されていないこと' do
    @css3.style['h3']['z-index'].should_not == '4'
  end

  it 'は、style.keys で順番にセレクタが得られること' do
    @css2.style.keys.should == @selectors2
  end

  it 'は、style[セレクタ].keys で順番にプロパティが得られること' do
    @css4.style['div .foo'].keys.should == ['color', 'background']
  end
end

describe Base, '} で終わらない CSS 文字列を指定してパースするとき' do
  before do
    @proc1 = Proc.new { TinyCss.new.read_string('h3 { color: red;') }
    @proc2 = Proc.new {
      TinyCss.new.read_string('h1, p { color: red }, f')
    }
    @proc3 = Proc.new {
      TinyCss.new.read_string('h1, p { color: red }, div { margin: 0')
    }
  end

  it 'は、例外 TinyCss::Error が発生すること' do
    msg = "Invalid or unexpected style data 'h3 { color: red;'"
    @proc1.should raise_error(Error, msg)
    msg = "Invalid or unexpected style data ', f'"
    @proc2.should raise_error(Error, msg)
    msg = "Invalid or unexpected style data ', div { margin: 0'"
    @proc3.should raise_error(Error, msg)
  end
end

describe Base, 'セレクタの後 { で始まらない CSS 文字列を指定してパースするとき' do
  before do
    @proc1 = Proc.new { TinyCss.new.read_string('h3 color: red; }') }
    @proc2 = Proc.new {
      TinyCss.new.read_string('h1, p { color: red }, div }')
    }
  end

  it 'は、例外 TinyCss::Error が発生すること' do
    msg = "Invalid or unexpected style data 'h3 color: red; }'"
    @proc1.should raise_error(Error, msg)

    msg = "Invalid or unexpected style data ', div }'"
    @proc2.should raise_error(Error, msg)
  end
end

describe Base, 'プロパティと値が : で区切られていないとき' do
  before do
    @proc = Proc.new { TinyCss.new.read_string('h3 { color }') }
  end

  it 'は、例外 TinyCss::Error が発生すること' do
    msg = "unexpected property ' color ' in style 'h3'"
    @proc.should raise_error(Error, msg)
  end
end

describe Base do
  before do
    @css = TinyCss.new.read(File.join(File.dirname(__FILE__), 'style.css'))
    @selectors = ['div', 'h1', 'h2', 'div#test', 'div.foo ul', 'p#hoge',
                  '.bar div']
  end

  describe Base, 'CSS ファイルを指定してパースするとき' do
    it 'は、self を返すこと' do
      @css.should be_instance_of(Base)
    end

    it 'は、style[セレクタ][プロパティ] で値が取り出せること' do
      @css.style['div']['padding'].should == '0'
      @css.style['div']['margin'].should == '0'
      @css.style['h1']['padding'].should == '0'
      @css.style['h1']['margin'].should == '0'
      @css.style['h2']['padding'].should == '0'
      @css.style['h2']['margin'].should == '0'
      @css.style['div#test']['border'].should == '1px solid black'
      @css.style['div#test']['padding'].should == '1px'
      @css.style['div#test']['padding-left'].should == '3px'
      @css.style['p#hoge']['color'].should == 'red'
      @css.style['p#hoge']['background'].should == '#ff0000'
    end

    it 'は、セレクタ文字列中のホワイトスペースが半角 1 スペースに変換されていること' do
      @css.style['div.foo ul']['list-style-type'].should == 'circle'
      @css.style['div.foo ul']['text-decoration'].should == 'underline'
    end

    it 'は、コメント内のスタイルが反映されていないこと' do
      @css.style['p#hoge']['font-size'].should_not == 'big'
    end

    it 'は、style.keys で順番にセレクタが得られること' do
      @css.style.keys.should == @selectors
    end

    it 'は、style[セレクタ].keys で順番にプロパティが得られること' do
      @css.style['.bar div'].keys.should == ['color', 'z-index', 'background']
    end

    it 'は、style.each で順番にセレクタとスタイルが得られること' do
      selectors, styles = [], []
      @css.style.each do |selector, style|
        selectors << selector
        styles << style
      end
      selectors.should == @selectors

      properties, values = [], []
      styles[3].each do |property, value|
        properties << property
        values << value
      end
      properties.should == ['border', 'padding', 'padding-left']
      values.should == ['1px solid black', '1px', '3px']
    end
  end

  describe Base, 'CSS 文字列を取得するとき' do
    before do
      @css.style['p#added']['background'] = 'yellow'
      @result = @css.write_string
    end

    it 'は、ソート(セレクタは逆ソート)されて整形されていること' do
      @result.should == "p#hoge {\n\tbackground: #ff0000;\n\tcolor: red;\n" +
        "\tz-index: 3;\n}\np#added {\n\tbackground: yellow;\n}\nh2 {\n\t" +
        "margin: 0;\n\tpadding: 0;\n}\nh1 {\n\tmargin: 0;\n\tpadding: 0;\n" +
        "}\ndiv.foo ul {\n\tlist-style-type: circle;\n\ttext-decoration: " +
        "underline;\n}\ndiv#test {\n\tborder: 1px solid black;\n\tpadding: " +
        "1px;\n\tpadding-left: 3px;\n}\ndiv {\n\tmargin: 0;\n\tpadding: 0;\n" +
        "}\n.bar div {\n\tbackground: #ff0000;\n\tcolor: red;\n\tz-index: " +
        "3;\n}\n"
    end

    it 'は、write_string で 第 1 引数に false を指定するとソートされないこと' do
      result = @css.write_string(false)
      result.should == "div {\n\tmargin: 0;\n\tpadding: 0;\n}\nh1 {\n\t" +
        "margin: 0;\n\tpadding: 0;\n}\nh2 {\n\tmargin: 0;\n\tpadding: 0;\n}" +
        "\ndiv#test {\n\tborder: 1px solid black;\n\tpadding: 1px;\n\t" +
        "padding-left: 3px;\n}\ndiv.foo ul {\n\tlist-style-type: circle;\n" +
        "\ttext-decoration: underline;\n}\np#hoge {\n\tbackground: #ff0000;\n" +
        "\tcolor: red;\n\tz-index: 3;\n}\n.bar div {\n\tbackground: #ff0000;" +
        "\n\tcolor: red;\n\tz-index: 3;\n}\np#added {\n\tbackground: yellow;" +
        "\n}\n"
    end
  end
end
