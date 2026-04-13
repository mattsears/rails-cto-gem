# frozen_string_literal: true

module RailsCto
  module Reporter
    private

    def render_section(title, color, items)
      return if items.empty?

      @shell.say "  #{title}:", color
      items.each { |item| @shell.say yield(item) }
    end
  end
end
