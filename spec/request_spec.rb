require_relative 'spec_helper'

RSpec.describe 'Request' do
  attr_reader :hash

  around do |spec|
    read_io, write_io = IO.pipe
    write_io.print "POST / HTTP/1.1\r\n",
                   "Host: localhost:8080\r\n",
                   "Connection: keep-alive\r\n",
                   "Cache-Control: max-age=0\r\n",
                   "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8\r\n",
                   "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.89 Safari/537.36\r\n",
                   "Accept-Encoding: gzip, deflate, sdch\r\n",
                   "Accept-Language: en-US,en;q=0.8\r\n",
                   "Content-Length: 15\r\n",
                   "Content-Type: application/x-www-form-urlencoded\r\n",
                   "\r\n",
                   "abc=123&def=456THE 456 SHOULD BE THE LAST THING READ!\r\n",
                   "(look around at the things you've found and think about why :)\r\n"
    write_io.close
    @hash = Request.parse(read_io)
    spec.call
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
