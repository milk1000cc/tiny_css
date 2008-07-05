require File.dirname(__FILE__) + '/../lib/tiny_css'
include TinyCss

describe Base do
  before do
    @css = TinyCss.new.read(File.join(File.dirname(__FILE__), 'style.css'))
    @selectors = ['div', 'h1', 'h2', 'div#test', 'div.foo ul', 'p#hoge',
                  '.bar div']
  end

  describe Base, 'CSS ファイルを指定してパースするとき' do
    it 'は、self を返すこと' do
      @css.should be_instance_of(TinyCss::Base)
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
