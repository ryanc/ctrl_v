require 'acceptance_helper'

describe 'The home page' do
  it 'redirects to the new paste page' do
    visit '/'
    expect(current_path).to eq('/new')
  end
end
