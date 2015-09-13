require_relative 'spec_helper'

RSpec.describe 'Request' do
  attr_accessor :hash

  around do |spec|
    begin
      read_io, write_io = IO.pipe
      write_io.print "POST /users HTTP/1.1\r\n",
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
                     "abc=123&def=456"

      self.hash = Request.parse(read_io)
      spec.call
    ensure
      read_io.close
      write_io.close
    end
  end

  context 'the first line' do
    it 'parses the first word as the REQUEST_METHOD' do
      expect(hash['REQUEST_METHOD']).to eq 'POST'
    end

    it 'parses the second word as the PATH_INFO' do
      expect(hash['PATH_INFO']).to eq '/users'
    end

    it 'parses the third word as the SERVER_PROTOCOL' do
      expect(hash['SERVER_PROTOCOL']).to eq 'HTTP/1.1'
    end
  end

  context 'the second line through the empty line' do
    specify 'take the form "Key: Value", and are added to the hash' do
      host = hash['Host'] || hash['HOST'] || hash['HTTP_HOST']
      expect(host).to eq "localhost:8080"
    end

    specify 'the keys have their dashes turned to underscores' do
      expect(hash['HTTP_HOST']).to eq "localhost:8080"
    end

    specify 'the keys are upcased, prepended with "HTTP_", and have their dashes turned to underscores' do
      expect(hash['HTTP_ACCEPT_LANGUAGE']).to eq "en-US,en;q=0.8"
    end

    it 'doesn\'t prepend HTTP_ to the content length or content type' do
      expect(hash['CONTENT_LENGTH']).to eq '15'
      expect(hash['CONTENT_TYPE']).to eq 'application/x-www-form-urlencoded'
    end
  end

  context 'everything after the empty line' do
    it 'is an io object that can be read in at the key "rack.input"' do
      expect(hash['rack.input'].read).to eq "abc=123&def=456"
    end
  end

  context 'A second test' do
    example 'just to make sure ;)' do
      read_io, write_io = IO.pipe
      write_io.print "GET /users/new HTTP/1.0\r\n",
                     "Cache-Control: max-age=0\r\n",
                     "Content-Length: 0\r\n",
                     "Content-Type: text/plain\r\n",
                     "\r\n"
      self.hash = begin  Request.parse(read_io)
                  ensure read_io.close
                         write_io.close
                  end

      expect(hash["REQUEST_METHOD"]).to     eq "GET"
      expect(hash["PATH_INFO"]).to          eq "/users/new"
      expect(hash["SERVER_PROTOCOL"]).to    eq "HTTP/1.0"
      expect(hash["HTTP_CACHE_CONTROL"]).to eq "max-age=0"
      expect(hash["CONTENT_LENGTH"]).to     eq "0"
      expect(hash["CONTENT_TYPE"]).to       eq "text/plain"
      expect(hash["rack.input"].read).to    eq ""
    end
  end
end
