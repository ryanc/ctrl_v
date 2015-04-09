require 'acceptance_helper'

describe 'The home page' do
  it 'redirects to the new paste page' do
    visit '/'
    expect(current_path).to eq('/new')
  end

  it 'should set the focus to the paste textarea' do
    visit '/new'
    expect(page).to have_css('textarea#paste[autofocus]')
  end

  it 'should not allow an empty paste' do
    click_button 'Paste It'
    expect(page).to have_content('The paste cannot be blank.')
  end
end
