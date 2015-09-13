require_relative 'spec_helper'

RSpec.describe 'Request' do
  attr_reader :hash

  around do |spec|
    File.open File.expand_path('fixtures/request.http', __dir__), 'r' do |file|
      @hash = Request.parse(file)
      spec.call
    end
  end

  context 'the first line' do
    it 'parses the method as REQUEST_METHOD' do
      expect(hash['REQUEST_METHOD']).to eq 'POST'
    end

    it 'parses the path as PATH_INFO' do
      expect(hash['PATH_INFO']).to eq '/'
    end

    it 'parses the protocol as SERVER_PROTOCOL' do
      expect(hash['SERVER_PROTOCOL']).to eq 'HTTP/1.1'
    end
  end

  context 'the headers' do
    specify 'are upcased, prepended with "HTTP_", and have their dashes turned to underscores' do
      expect(hash['HTTP_ACCEPT_LANGUAGE']).to eq "en-US,en;q=0.8"
    end

    it 'doesn\'t prepend HTTP_ to the content length or content type' do
      expect(hash['CONTENT_LENGTH']).to eq '15'
      expect(hash['CONTENT_TYPE']).to eq 'application/x-www-form-urlencoded'
    end
  end

  context 'the body' do
    it 'is an io object at the key "rack.input"pointing at the first character of the body' do
      expect(hash['rack.input'].read).to eq "abc=123&def=456"
    end
  end
end
