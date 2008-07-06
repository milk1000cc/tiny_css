module TinyCss
  class Base
    attr_accessor :style

    def initialize
      @style = OrderedHash.new
    end

    def read(file)
      read_string open(file).read
    end

    def read_string(string)
      string = string.tr("\n\t", '  ').gsub(%r!/\*.*?\*/!, '')

      split_by_closing_brace(string).reject { |v| v !~ /\S/ }.each do |v|
        unless match = v.match(/^\s*([^{]+?)\s*\{(.*)\}\s*$/)
          raise Error, "Invalid or unexpected style data '#{ v }'"
        end

        style = match.captures.first
        styles = style.gsub(/\s+/, ' ').split(/\s*,\s*/).
          reject { |v| v !~ /\S/ }

        match.captures.last.split(/\;/).reject { |v| v !~ /\S/ }.each do |v|
          unless match = v.match(/^\s*([\w._-]+)\s*:\s*(.*?)\s*$/)
            raise Error, "unexpected property '#{ v }' in style '#{ style }'"
          end
          styles.each do |v|
            @style[v][match.captures.first.downcase] = match.captures.last
          end
        end
      end

      self
    end

    def write(file, sort = true)
      open(file, 'w').write write_string(sort)
    end

    def write_string(sort = true)
      style = @style.dup
      contents = ''
      selectors = style.keys
      selectors.sort!.reverse! if sort
      selectors.each do |selector|
        contents += "#{ selector } {\n"
        keys = style[selector].keys
        keys.sort! if sort
        keys.each { |k| contents += "\t#{ k }: #{ @style[selector][k] };\n" }
        contents += "}\n"
      end

      contents
    end

    private
    def split_by_closing_brace(string)
      pattern = /(.+?\})/
      ary = []

      if string =~ pattern
        string.gsub(pattern) { |matched| ary << matched }
        if match = string.match(/.+\}(.+)$/)
          ary << match.captures.first
        end
      else
        ary << string
      end

      ary
    end
  end
end
