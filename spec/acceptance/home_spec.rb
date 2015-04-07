require 'acceptance_helper'

describe 'The home page' do
  it 'redirects to the new paste page' do
    visit '/'
    expect(current_path).to eq('/new')
  end

  it 'should not allow an empty paste' do
    click_button 'Paste It'
    expect(page).to have_content('The paste cannot be blank.')
  end
end
