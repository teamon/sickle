require File.join(File.dirname(__FILE__), "..", "lib", "sickle")

module Sub
  include Sickle::Runner

  desc "Run task Sub1"
  def sub1
    p ["sub1"]
  end

  desc "Will make conflict!"
  def conflict
    p ["sub1:conflict"]
  end
end

module Other
  include Sickle::Runner

  desc "Run task other sub1"
  def other1(blah)
    p ["other1", blah]
  end

  desc "Will make conflict!"
  def conflict
    p ["other1:conflict"]
  end
end

module NoSub
  include Sickle::Runner

  desc "No sub for me"
  def nosub
    p ["nosub"]
  end

  desc "Will make conflict!"
  def conflict
    p ["nosub:conflict"]
  end
end

class App
  include Sickle::Runner

  global_flag :verbose
  global_option :debug

  before do
    $verbose = options[:verbose]
  end

  desc "Run task 1"
  flag :quiet
  option :with_prefix
  def task1(a, b, c = "def")
    p ["task1", a, b, c, options[:quiet], options[:verbose], options[:debug], options[:with_prefix]]
  end

  desc "Run task 2"
  flag :fast
  flag :slow
  option :number, :default => 10
  def task2
    p ["task2", options[:number], options[:fast], options[:slow], options[:verbose], options[:debug]]
  end

  desc "Will make conflict!"
  def conflict
    p ["app:conflict"]
  end

  option :null, :default => nil
  desc "Test"
  def test_option
    p ["test_option", options[:null]]
  end

  def private_task
  end


  include_modules :sub    => Sub,
                  :other  => Other

  include NoSub
end
