require_relative 'spec_helper'

RSpec.describe 'Response test' do
  it 'creates an HTTP response, given a status code, hash of headers, and array of strings for the body' do
    allowed_methods = {
      String      => ['#chomp', '#split', '#to_i', '#upcase', '#gsub', '#==', '#!=', '#<<'],
      Hash        => ['#[]=', '#[]', '#each'],
      IO          => ['#gets', '#read'],
      StringIO    => ['.new'],
      Response    => ['.to_http'],
      Kernel      => ['#loop', '#inspect', '#to_s'],
      Array       => ['#each'],
      BasicObject => ['#initialize'],
    }

    actual = restrict_methods allowed_methods do
      status_code = 404
      headers     = {'this-is-a-header' => 'and-a-value'}
      body        = ["This is", " a body"]
      Response.to_http(status_code, headers, body)
    end

    # HTTP/1.1 will be hard-coded in there
    expected = "HTTP/1.1 404\r\n"                  +
               "this-is-a-header: and-a-value\r\n" +
               "\r\n"                              +
               "This is a body"

    expect(actual).to eq expected
  end
end
