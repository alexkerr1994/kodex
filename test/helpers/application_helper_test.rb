require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  # Mon 1 June 2026 .. Sun 7 June 2026
  WEEK = (Date.new(2026, 6, 1)..Date.new(2026, 6, 7)).to_a

  def span(from, to)
    { event: :e, from: Date.parse(from), to: Date.parse(to) }
  end

  test "a span inside the week gets the right column and width" do
    bar = week_span_bars(WEEK, [ span("2026-06-02", "2026-06-04") ]).first
    assert_equal 2, bar[:col]
    assert_equal 3, bar[:span]
    assert_equal 0, bar[:lane]
    assert_not bar[:continues_left]
    assert_not bar[:continues_right]
  end

  test "a span crossing the week start is clipped and flagged" do
    bar = week_span_bars(WEEK, [ span("2026-05-30", "2026-06-02") ]).first
    assert_equal 1, bar[:col]
    assert_equal 2, bar[:span]
    assert bar[:continues_left]
    assert_not bar[:continues_right]
  end

  test "a span crossing the week end is flagged continues_right" do
    bar = week_span_bars(WEEK, [ span("2026-06-06", "2026-06-10") ]).first
    assert_equal 6, bar[:col]
    assert_equal 2, bar[:span]
    assert bar[:continues_right]
  end

  test "overlapping spans land on different lanes" do
    bars = week_span_bars(WEEK, [ span("2026-06-02", "2026-06-04"), span("2026-06-03", "2026-06-05") ])
    assert_equal [ 0, 1 ], bars.map { |b| b[:lane] }.sort
  end

  test "non-overlapping spans reuse a lane" do
    bars = week_span_bars(WEEK, [ span("2026-06-01", "2026-06-02"), span("2026-06-05", "2026-06-06") ])
    assert_equal [ 0, 0 ], bars.map { |b| b[:lane] }
  end

  test "a span entirely outside the week is dropped" do
    assert_empty week_span_bars(WEEK, [ span("2026-06-20", "2026-06-25") ])
  end
end
