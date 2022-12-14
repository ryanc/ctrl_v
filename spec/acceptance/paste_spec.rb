require 'acceptance_helper'

describe 'The paste view' do
  it 'should display the creation date' do
    paste = Paste.create(
      content: "This is a test.",
      ip_addr: '127.0.0.1',
    )
    visit "/p/#{paste.id_b62}"
    expect(page).to have_content(/Created.+ago/)
  end

  it 'should display the expiration date' do
    paste = Paste.create(
      content: "This is a test.",
      ip_addr: '127.0.0.1',
      expires_at: Time.now + 3600,
    )
    visit "/p/#{paste.id_b62}"
    expect(page).to have_content(/Expires in/)
  end
end
