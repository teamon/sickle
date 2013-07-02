require "minitest/autorun"
require "minitest/pride"

require File.join(File.dirname(__FILE__), "test_app")

describe Sickle do
  describe "DSL" do
    it "list of global options" do
      App.__global_options.keys.must_equal ["verbose", "debug"]
    end

    it "list of commands" do
      App.__commands.keys.must_equal(
        %w(help task1 task2 conflict test_option sub:sub1 sub:conflict other:other1 other:conflict nosub))
    end

    it "correct commands descriptions" do
      App.__commands["task1"].desc.must_equal "Run task 1"
      App.__commands["task2"].desc.must_equal "Run task 2"
      App.__commands["sub:sub1"].desc.must_equal "Run task Sub1"
      App.__commands["other:other1"].desc.must_equal "Run task other sub1"
      App.__commands["nosub"].desc.must_equal "No sub for me"
    end

    it "correct commands options" do
      App.__commands["task1"].options.keys.must_equal [:quiet, :with_prefix]
      App.__commands["task2"].options.keys.must_equal [:fast, :slow, :number]
    end
  end

  describe "Runner" do
    it "task1" do
      App.run(["task1", "x", "y"]).must_equal(
        ["task1", "x", "y", "def", false, false, nil, nil])
      App.run(["task1", "x", "y", "z", "--verbose", "--with-prefix", "some/path/to"]).must_equal(
        ["task1", "x", "y", "z", false, true, nil, "some/path/to"])
      App.run(["task1", "--verbose", "x", "y"]).must_equal(
        ["task1", "x", "y", "def", false, true, nil, nil])
    end

    it "task2" do
      App.run(["task2"]).must_equal(
        ["task2", 10, false, false, false, nil])
      App.run(%w(task2 --fast)).must_equal(
        ["task2", 10, true, false, false, nil])
      App.run(%w(task2 --slow)).must_equal(
        ["task2", 10, false, true, false, nil])
      App.run(%w(task2 --verbose)).must_equal(
        ["task2", 10, false, false, true, nil])
      App.run(%w(task2 --debug 1)).must_equal(
        ["task2", 10, false, false, false, "1"])
      App.run(%w(task2 --fast --slow --verbose)).must_equal(
        ["task2", 10, true, true, true, nil])
      App.run(%w(task2 --number 40)).must_equal(
        ["task2", 40, false, false, false, nil])
    end

    it "sub:sub1" do
      App.run(%w(sub:sub1)).must_equal(
        ["sub1"])
    end

    it "conflict" do
      App.run(%w(conflict)).must_equal ["nosub:conflict"]
      App.run(%w(sub:conflict)).must_equal ["sub1:conflict"]
      App.run(%w(other:conflict)).must_equal ["other1:conflict"]
    end

    it "option with nil default" do
      App.run(%w(test_option)).must_equal ["test_option", nil]
      App.run(%w(test_option --null foo)).must_equal ["test_option", "foo"]
    end
  end
end
