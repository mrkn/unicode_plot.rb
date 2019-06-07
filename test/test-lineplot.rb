require 'date'

class LineplotTest < Test::Unit::TestCase
  include Helper::Fixture
  include Helper::WithTerm

  sub_test_case("UnicodePlot.lineplot") do
    def setup
      @x = [-1, 1, 3, 3, -1]
      @y = [2, 0, -5, 2, -5]
    end

    test("ArgumentError") do
      assert_raise(ArgumentError) { UnicodePlot.lineplot() }
      assert_raise(ArgumentError) { UnicodePlot.lineplot(Math.method(:sin), @x, @y) }
      assert_raise(ArgumentError) { UnicodePlot.lineplot([], 0, 3) }
      assert_raise(ArgumentError) { UnicodePlot.lineplot([], @x) }
      assert_raise(ArgumentError) { UnicodePlot.lineplot([]) }
      assert_raise(ArgumentError) { UnicodePlot.lineplot([1, 2], [1, 2, 3]) }
      assert_raise(ArgumentError) { UnicodePlot.lineplot([1, 2, 3], [1, 2]) }
      assert_raise(ArgumentError) { UnicodePlot.lineplot([1, 2, 3], 1..2) }
      assert_raise(ArgumentError) { UnicodePlot.lineplot(1..3, [1, 2]) }
      assert_raise(ArgumentError) { UnicodePlot.lineplot(1..3, 1..2) }
    end

    sub_test_case("with numeric array") do
      test("default") do
        plot = UnicodePlot.lineplot(@x, @y)
        _, output = with_term { plot.render($stdout) }
        assert_equal(fixture_path("lineplot/default.txt").read,
                     output)

        plot = UnicodePlot.lineplot(@x.map(&:to_f), @y)
        _, output = with_term { plot.render($stdout) }
        assert_equal(fixture_path("lineplot/default.txt").read,
                     output)

        plot = UnicodePlot.lineplot(@x, @y.map(&:to_f))
        _, output = with_term { plot.render($stdout) }
        assert_equal(fixture_path("lineplot/default.txt").read,
                     output)
      end

      test("y only") do
        plot = UnicodePlot.lineplot(@y)
        _, output = with_term { plot.render($stdout) }
        assert_equal(fixture_path("lineplot/y_only.txt").read,
                     output)
      end

      test("range") do
        plot = UnicodePlot.lineplot(6..10)
        _, output = with_term { plot.render($stdout) }
        assert_equal(fixture_path("lineplot/range1.txt").read,
                     output)

        plot = UnicodePlot.lineplot(11..15, 6..10)
        _, output = with_term { plot.render($stdout) }
        assert_equal(fixture_path("lineplot/range2.txt").read,
                     output)
      end
    end

    test("axis scaling and offsets") do
      plot = UnicodePlot.lineplot(
        @x.map {|x| x * 1e+3 + 15 },
        @y.map {|y| y * 1e-3 - 15 }
      )
      _, output = with_term { plot.render($stdout) }
      assert_equal(fixture_path("lineplot/scale1.txt"),
                   output)

      plot = UnicodePlot.lineplot(
        @x.map {|x| x * 1e-3 + 15 },
        @y.map {|y| y * 1e+3 - 15 }
      )
      _, output = with_term { plot.render($stdout) }
      assert_equal(fixture_path("lineplot/scale2.txt"),
                   output)

      tx = [-1.0, 2, 3, 700000]
      ty = [1.0, 2, 9, 4000000]
      plot = UnicodePlot.lineplot(tx, ty)
      _, output = with_term { plot.render($stdout) }
      assert_equal(fixture_path("lineplot/scale3.txt"),
                   output)

      plot = UnicodePlot.lineplot(tx, ty, width: 5, height: 5)
      _, output = with_term { plot.render($stdout) }
      assert_equal(fixture_path("lineplot/scale3_small.txt"),
                   output)
    end

    test("dates") do
      d = [*Date.new(1999, 12, 31) .. Date.new(2000, 1, 30)]
      v = 0.step(3*Math::PI, by: 3*Math::PI / 30)

      y1 = v.map(&Math.method(:sin))
      plot = UnicodePlot.lineplot(d, y1, name: "sin", height: 5, xlabel: "date")
      _, output = with_term { plot.render($stdout) }
      assert_equal(fixture_path("lineplot/dates1.txt").read,
                   output)

      y2 = v.map(&Math.method(:cos))
      assert_same(plot,
                  UnicodePlot.lineplot!(plot, d, y2, name: "cos"))

      _, output = with_term { plot.render($stdout) }
      assert_equal(fixture_path("lineplot/dates2.txt").read,
                   output)
    end

    test("line with intercept and slope") do
      plot = UnicodePlot.lineplot(@y)
      assert_same(plot,
                  UnicodePlot.lineplot!(plot, -3, 1))
      _, output = with_term { plot.render($stdout) }
      assert_equal(fixture_path("lineplot/slope1.txt").read,
                   output)

      assert_same(plot,
                  UnicodePlot.lineplot!(plot, -4, 0.5, color: :cyan, name: "foo"))
      _, output = with_term { plot.render($stdout) }
      assert_equal(fixture_path("lineplot/slope2.txt").read,
                   output)
    end

    # TODO: functions

    # TODO: stairs
  end
end
