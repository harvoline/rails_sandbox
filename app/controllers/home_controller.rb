class HomeController < ApplicationController

  def index
    @docs = "
    Some documentation on how it works

    TEMPLATE: tag_name#element_id#element_class value

    Example : table#table_1#stripe
    Output : <table id='table_1' class='stripe'></table>

    Example : td#table_data#odd Heading 1
    Output : <td id='table_data' class='odd'>Heading 1</td>
    "

    @sample = "table#table_1#stripe
\tthead
\t\ttr
\t\t\ttd#table_data#odd Heading 1
\t\t\ttd Heading 2
\ttbody
\t\ttr
\t\t\ttd Body 1
\t\t\ttd Body 2

div
\tdiv#card
\t\tdiv#card-title
\t\tdiv#card-body
"
  end

  def parser
    
    @input_raw = params['input']
    @input_to_html = ""
    
    input = params['input'].split("\r\n")

    $closing_tag = []
    tab = 0
    prev_tab = 0

    if input.count > 0
      input.each_with_index do |line, index|
        next if line.lstrip.empty?
        is_a_child = false

        if line[0].match(/[\t]/)
          is_a_child = true
          prev_tab = tab
          tab = line.count("\t")
          strip_line = line.lstrip
        end

        if is_a_child
          while tab <= prev_tab
            if $closing_tag.count > 0
              @input_to_html += $closing_tag.pop
            end

            prev_tab -= 1
          end

          @input_to_html += self.parse_input(strip_line, line)
        else
          tab = 0

          if $closing_tag.count > 0
            while $closing_tag.count > 0
              @input_to_html += $closing_tag.pop
            end
          end

          @input_to_html += self.parse_input(line)
        end
      end

      if $closing_tag.count > 0
        while $closing_tag.count > 0
          @input_to_html += $closing_tag.pop
        end
      end
    else
      @input_to_html
    end
  end

  private
  
  def parse_input(line, parent = nil)
    value = nil

    line_data = line.split(/[ ]/)

    if line_data.second
      value = line_data[1..-1].join(" ")
    end

    if line_data.first.empty?
      return false
    end

    chunks = line_data.first.split("#")

    if chunks.first.empty?
      return false
    end

    input_html = self.build_tag(chunks, value)
  end

  def build_tag(tag_data, value = nil)
    tag_html = "<#{tag_data[0]}"

    if tag_data[1] and !tag_data[1].empty?
      tag_html += " id='#{tag_data[1]}'"
    end

    if tag_data[2] and !tag_data[2].empty?
      tag_html += " class='#{tag_data[2]}'"
    end

    if value
      tag_html += ">#{value}"
    else
      tag_html += ">"
    end

    $closing_tag.append("</#{tag_data[0]}>")

    tag_html
  end
end
