require_relative 'spec_helper'

RSpec.describe 'Response test' do
  it 'creates an HTTP response, given a status code, hash of headers, and array of strings for the body' do
    status_code = 404
    headers     = {'this-is-a-header' => 'and-a-value'}
    body        = ["This is", " a body"]

    actual   = Response.to_http(status_code, headers, body)

    # HTTP/1.1 will be hard-coded in there
    expected = "HTTP/1.1 404\r\n"                  +
               "this-is-a-header: and-a-value\r\n" +
               "\r\n"                              +
               "This is a body"

    expect(actual).to eq expected
  end
end
