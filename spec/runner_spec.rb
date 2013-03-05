require "minitest/spec"
require "minitest/autorun"
require "turn"

require File.join(File.dirname(__FILE__), "test_app")

describe Sickle do
  describe "DSL" do
    it "list of global options" do
      App.__global_options.keys.must_equal ["verbose", "debug"]
    end

    it "list of commands" do
      App.__commands.keys.must_equal(
        %w(task1 task2 conflict sub:sub1 sub:conflict other:other1 other:conflict nosub))
    end

    it "correct commands descriptions" do
      App.__commands["task1"].desc.must_equal "Run task 1"
      App.__commands["task2"].desc.must_equal "Run task 2"
      App.__commands["sub:sub1"].desc.must_equal "Run task Sub1"
      App.__commands["other:other1"].desc.must_equal "Run task other sub1"
      App.__commands["nosub"].desc.must_equal "No sub for me"
    end

    it "correct commands options" do
      App.__commands["task1"].options.keys.must_equal [:quiet]
      App.__commands["task2"].options.keys.must_equal [:fast, :slow, :number]
    end
  end

  describe "Runner" do
    it "task1" do
      App.run(["task1", "x", "y"]).must_equal(
        ["task1", "x", "y", "def", false, false, false])
      App.run(["task1", "x", "y", "z", "--verbose"]).must_equal(
        ["task1", "x", "y", "z", false, true, false])
    end

    it "task2" do
      App.run(["task2"]).must_equal(
        ["task2", 10, false, false, false, false])
      App.run(%w(task2 --fast)).must_equal(
        ["task2", 10, true, false, false, false])
      App.run(%w(task2 --slow)).must_equal(
        ["task2", 10, false, true, false, false])
      App.run(%w(task2 --verbose)).must_equal(
        ["task2", 10, false, false, true, false])
      App.run(%w(task2 --debug)).must_equal(
        ["task2", 10, false, false, false, true])
      App.run(%w(task2 --fast --slow --verbose)).must_equal(
        ["task2", 10, true, true, true, false])
      App.run(%w(task2 --number 40)).must_equal(
        ["task2", 40, false, false, false, false])
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
  end
end
