# Helpers for manipulating the Markdown source of a note.
module NoteMarkdown
  # Matches a GFM task-list line, capturing the parts around the checkbox mark
  # so only the mark itself is rewritten: "  - [ ] text" / "* [x] text".
  TASK_LINE = /\A(\s*[-*+]\s+\[)[ xX](\].*)\z/m

  # Flip the Nth (0-based) task-list item's checkbox to `checked`, returning the
  # new source. `index` corresponds to the order checkboxes render in the preview.
  def self.toggle_task(body, index, checked)
    seen = -1
    body.to_s.lines.map do |line|
      if line =~ TASK_LINE
        seen += 1
        seen == index ? "#{$1}#{checked ? 'x' : ' '}#{$2}" : line
      else
        line
      end
    end.join
  end
end
