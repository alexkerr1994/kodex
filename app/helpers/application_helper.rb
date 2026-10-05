module ApplicationHelper
  # Minimal inline line-icon set (Feather/Lucide-style paths). Usage: <%= icon(:tag) %>
  ICONS = {
    book:     %(<path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/>),
    search:   %(<circle cx="11" cy="11" r="7"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>),
    plus:     %(<line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>),
    settings: %(<circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/>),
    folder:   %(<path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/>),
    tag:      %(<path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"/><line x1="7" y1="7" x2="7.01" y2="7"/>),
    share:    %(<path d="M4 12v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-8"/><polyline points="16 6 12 2 8 6"/><line x1="12" y1="2" x2="12" y2="15"/>),
    expand:   %(<path d="M8 3H5a2 2 0 0 0-2 2v3m18 0V5a2 2 0 0 0-2-2h-3m0 18h3a2 2 0 0 0 2-2v-3M3 16v3a2 2 0 0 0 2 2h3"/>),
    comment:  %(<path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>),
    more:     %(<circle cx="12" cy="12" r="1.4"/><circle cx="19" cy="12" r="1.4"/><circle cx="5" cy="12" r="1.4"/>),
    star:     %(<polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/>),
    archive:  %(<polyline points="21 8 21 21 3 21 3 8"/><rect x="1" y="3" width="22" height="5"/><line x1="10" y1="12" x2="14" y2="12"/>),
    trash:    %(<polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>),
    pencil:   %(<path d="M12 20h9"/><path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4z"/>),
    notes:    %(<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="8" y1="13" x2="16" y2="13"/><line x1="8" y1="17" x2="13" y2="17"/>),
    users:    %(<path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/>),
    calendar: %(<rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/>),
    close:    %(<line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>),
    chevron:  %(<polyline points="6 9 12 15 18 9"/>),
    board:    %(<rect x="3" y="4" width="5" height="16" rx="1"/><rect x="10" y="4" width="5" height="10" rx="1"/><rect x="17" y="4" width="4" height="13" rx="1"/>),
    collapse: %(<rect x="3" y="4" width="18" height="16" rx="2"/><line x1="9" y1="4" x2="9" y2="20"/>),
    kodex:    %(<line x1="12" y1="3" x2="12" y2="21"/><line x1="12" y1="12" x2="4" y2="4"/><line x1="12" y1="12" x2="4" y2="20"/><line x1="12" y1="12" x2="20" y2="4"/><line x1="12" y1="12" x2="20" y2="20"/>),
    logout:   %(<path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/>)
  }.freeze

  def icon(name, size: 20, weight: 1.7)
    paths = ICONS[name.to_sym]
    return "".html_safe unless paths

    content_tag(:svg, paths.html_safe,
      class: "icon", width: size, height: size, viewBox: "0 0 24 24",
      fill: "none", stroke: "currentColor", "stroke-width": weight,
      "stroke-linecap": "round", "stroke-linejoin": "round",
      xmlns: "http://www.w3.org/2000/svg")
  end

  # The KODEX mark rendered as a filled rounded-square badge (mark knocked out).
  def kodex_badge(size: 40, weight: 2.6)
    content_tag(:svg, width: size, height: size, viewBox: "0 0 24 24",
      xmlns: "http://www.w3.org/2000/svg", class: "icon kodex-badge") do
      shape = tag.rect(x: 1, y: 1, width: 22, height: 22, rx: 6, fill: "currentColor")
      mark = content_tag(:g, ICONS[:kodex].html_safe,
        fill: "none", stroke: "var(--accent-contrast)", "stroke-width": weight,
        "stroke-linecap": "round", "stroke-linejoin": "round",
        transform: "translate(3.6 3.6) scale(0.7)")
      safe_join([shape, mark])
    end
  end

  MARKDOWN_OPTIONS = {
    extension: {
      tasklist: true, table: true, strikethrough: true,
      autolink: true, tagfilter: true
    },
    # unsafe: false strips/escapes raw HTML, so user notes can't inject scripts.
    render: { unsafe: false }
  }.freeze

  WEEK_HOUR_PX = 44
  def week_hour_px = WEEK_HOUR_PX

  # Lay out a day's timed events for the week grid: pixel top/height (by time and
  # duration) and lane/lanes for side-by-side placement of overlapping events.
  def week_event_layout(events)
    timed = events.reject(&:all_day?).sort_by(&:starts_at)
    lane_ends = []
    placed = timed.map do |event|
      start_min = event_minutes(event.starts_at)
      end_min = event.ends_at ? event_minutes(event.ends_at) : start_min + 60
      # Overnight (ends next day) or missing end → run to the end of the day.
      end_min = 1440 if end_min <= start_min
      end_min = [end_min, 1440].min
      lane = lane_ends.index { |e| e <= start_min } || lane_ends.size
      lane_ends[lane] = end_min
      { event: event, start: start_min, end: end_min, lane: lane }
    end
    total = [lane_ends.size, 1].max
    placed.map do |p|
      { event: p[:event],
        top: (p[:start] / 60.0 * WEEK_HOUR_PX).round(1),
        height: [(p[:end] - p[:start]) / 60.0 * WEEK_HOUR_PX, 20].max.round(1),
        left: (p[:lane].to_f / total * 100).round(2),
        width: (100.0 / total).round(2) }
    end
  end

  # Place multi-day spans within a single week (7 ascending Date objects) into
  # non-overlapping lanes for the continuous-bar month render. Each returned bar
  # carries its 1-based column, span width, lane row, and whether it continues
  # past this week's edges (so the bar can round only its true ends).
  def week_span_bars(week_days, spans)
    wk_start = week_days.first
    wk_end = week_days.last
    bars = (spans || []).filter_map do |sp|
      next if sp[:to] < wk_start || sp[:from] > wk_start + 6

      seg_start = [sp[:from], wk_start].max
      seg_end = [sp[:to], wk_end].min
      { event: sp[:event],
        col: (seg_start - wk_start).to_i + 1,
        span: (seg_end - seg_start).to_i + 1,
        continues_left: sp[:from] < wk_start,
        continues_right: sp[:to] > wk_end }
    end

    # Greedy lane packing: longest/earliest first, lowest free lane.
    bars.sort_by! { |b| [b[:col], -b[:span]] }
    lane_last = []
    bars.each do |b|
      lane = (0..lane_last.size).find { |l| lane_last[l].nil? || lane_last[l] < b[:col] }
      b[:lane] = lane
      lane_last[lane] = b[:col] + b[:span] - 1
    end
    bars
  end

  def event_minutes(time)
    t = time.in_time_zone
    t.hour * 60 + t.min
  end

  def markdown(text)
    return "".html_safe if text.blank?

    Commonmarker.to_html(text, options: MARKDOWN_OPTIONS).html_safe
  end

  # A square, resized avatar thumbnail (avoids serving the full-size upload).
  # px is the CSS display size; we render at 2× for retina sharpness.
  def avatar_image_tag(user, px)
    image_tag user.avatar.variant(resize_to_fill: [px * 2, px * 2]), class: "avatar-img", alt: user.display_name
  end

  # The current user's relationship to a note, for the card/badge label.
  def note_role(note, user = current_user)
    return "Owner" if note.owner_id == user.id
    note.editable_by?(user) ? "Editor" : "Viewer"
  end

  # A plain-text preview of a note body with Markdown punctuation stripped.
  def note_snippet(note, length: 64)
    plain = note.body.to_s
      .gsub(/^\s*[-*+]\s+/, " ")               # list markers at line start
      .gsub(/[#*_>`~\[\]]|\!\[.*?\]\(.*?\)/, " ") # other markdown punctuation (keep inline hyphens)
      .squish
    plain.present? ? truncate(plain, length: length) : "No additional text"
  end
end
