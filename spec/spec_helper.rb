# help the module1 students get bootstrapped
def self.explain_error(explanation)
  $stderr.puts explanation
  exit! 1
end

['lib/request', 'lib/response'].each do |path|
  begin
    require_relative "../#{path}"
  rescue LoadError
    explain_error "We can't find the file that is supposed to have your code in it (#{path}.rb)... press return and then go make it!"
  rescue SyntaxError => e
    explain_error "Looks like your code isn't valid Ruby. Try commenting out the last thing you did until it doesn't blow up for this reason, then look at the commented portion to figure out why! The actual error message is is: \n\n#{e.message}"
  end
end

def all_methods(klass)
  instance_methods = klass.instance_methods + klass.private_instance_methods + klass.protected_instance_methods
  methods          = klass.methods + klass.private_methods + klass.protected_methods
  methods.sort.map { |m| ".#{m}" } + instance_methods.sort.map { |m| "##{m}" }
end

def default_allowed_methods
  { String      => ['#chomp', '#split', '#to_i', '#upcase', '#gsub', '#==', '#!=', '#<<'],
    Hash        => ['#[]=', '#[]', '#each'],
    IO          => ['#gets', '#read'],
    Class       => ['#new'],
    Request     => all_methods(Request),
    Response    => all_methods(Response),
    Kernel      => ['#loop', '#inspect', '#to_s'],
    Array       => ['#each'],
    BasicObject => ['#initialize'],
  }
end

def is_exception?(obj)
  obj.kind_of?(Exception) || (obj.kind_of?(Class) && obj < Exception)
end

require 'pathname'
def restrict_methods(allowed_methods=default_allowed_methods, called_from:nil, &block)
  within_pry = false

  tp = TracePoint.new :c_call, :c_return, :call, :return do |tp|
    if tp.event == :return || tp.event == :c_return
      within_pry = false if tp.method_id == :pry
      next
    elsif within_pry || is_exception?(tp.self)
      next
    elsif called_from && Pathname.new(called_from) != Pathname.new(tp.path).basename.sub_ext('')
      next
    else
      if [:binding, :pry, :__method__].include? tp.method_id
        within_pry = true
      end
      next if within_pry
    end

    klass = nil
    begin klass = tp.self.singleton_class
    rescue TypeError # eg no singleton for Fixnum
      klass = tp.self.class
    end

    instance_methods = klass.ancestors.flat_map do |ancestor|
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
