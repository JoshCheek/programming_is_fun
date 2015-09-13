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

RSpec.configure do |config|
  config.fail_fast = true
  config.color     = true
end
