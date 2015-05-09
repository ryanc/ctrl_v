require 'helpers'

RSpec.configure do |c|
  c.include ViewHelpers
end

describe 'sinatra view helpers' do
  it 'should display the application git revision' do
    expect(File).to receive(:readable?).and_return(true)
    expect(IO).to receive(:read).and_return("abcdefg\n")
    revision = app_revision
    expect(revision).to eq("abcdefg")
  end

  it 'should display unknown if application git revision is not present' do
    expect(File).to receive(:readable?).and_return(false)
    revision = app_revision
    expect(revision).to eq("unknown")
  end
end
