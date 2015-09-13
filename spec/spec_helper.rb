# help the module1 students get bootstrapped
def self.explain_error(explanation)
  $stderr.puts explanation
  $stdin.gets
  exit! 1
end

begin
  path = 'lib/programming_is_fun'
  require_relative "../#{path}"
rescue LoadError
  explain_error "We can't find the file that is supposed to have your code in it (#{path}.rb)... press return and then go make it!"
rescue SyntaxError => e
  explain_error "Looks like your code isn't valid Ruby. Try commenting out the last thing you did until it doesn't blow up for this reason, then look at the commented portion to figure out why! The actual error message is is: \n\n#{e.message}"
end

def default_allowed_methods
  { String      => ['#chomp', '#split', '#to_i', '#upcase', '#gsub', '#==', '#!=', '#<<'],
    Hash        => ['#[]=', '#[]', '#each'],
    IO          => ['#gets', '#read'],
    StringIO    => ['.new'],
    Request     =>  Request.methods.map { |m| ".#{m}" } +  Request.instance_methods.map { |m| "##{m}" },
    Response    => Response.methods.map { |m| ".#{m}" } + Response.instance_methods.map { |m| "##{m}" },
    Kernel      => ['#loop', '#inspect', '#to_s'],
    Array       => ['#each'],
    BasicObject => ['#initialize'],
  }
end

def restrict_methods(allowed_methods=default_allowed_methods, &block)
  within_pry = false

  tp = TracePoint.new :c_call, :c_return, :call, :return do |tp|
    if tp.event == :return || tp.event == :c_return
      within_pry = false if tp.method_id == :pry
      next
    elsif within_pry
      next
    else
      if [:binding, :pry, :__method__].include? tp.method_id
        within_pry = true
      end
      next if within_pry
    end

    instance_methods = tp.self.class.ancestors.flat_map do |ancestor|
      allowed_methods
        .fetch(ancestor, [])
        .select { |m| m.to_s.start_with? '#' }
        .map    { |m| m.to_s[1..-1].to_sym }
    end

    singleton_methods = allowed_methods
                          .fetch(tp.self, [])
                          .select { |m| m.to_s[0] == '.' }
                          .map    { |m| m.to_s[1..-1].to_sym }

    all_methods = instance_methods + singleton_methods

    all_methods.include?(tp.method_id) ||
      raise("You called #{tp.method_id.inspect} on #{tp.self.inspect}, but are only allowed to call these on that object: #{all_methods.inspect}")
  end
  tp.enable(&block)
end

RSpec.configure do |config|
  config.fail_fast = true
  config.color     = true
end
