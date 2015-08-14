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

  it 'should default to enabling syntax highlighting' do
    visit '/new'
    expect(page).to have_checked_field('Syntax highlighting?')
  end

  it 'should not allow an empty paste' do
    click_button 'Paste It'
    expect(page).to have_content('The paste cannot be blank.')
  end

  it 'should display the git revision in the footer' do
    visit '/new'
    expect(page).to have_content("Revision:")
  end
end
