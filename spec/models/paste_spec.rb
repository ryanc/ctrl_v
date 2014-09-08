describe Paste do
  before do
    @paste = Paste.create(
      filename: 'test.txt',
      highlighted: true,
      ip_addr: '127.0.0.1',
      content: 'Testing ... 1 ... 2 ... 3',
    )
  end

  subject { @paste }

  it { is_expected.to respond_to(:id) }
  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:id_b62) }
  it { is_expected.to respond_to(:filename) }
  it { is_expected.to respond_to(:highlighted) }
  it { is_expected.to respond_to(:ip_addr) }
  it { is_expected.to respond_to(:created_at) }
  it { is_expected.to respond_to(:updated_at) }
  it { is_expected.to respond_to(:content) }
  it { is_expected.to respond_to(:view_count) }

  it 'should not be highlighted' do
    @paste.highlighted = nil
    expect(@paste.highlighted?).to be false

    @paste.highlighted = ''
    expect(@paste.highlighted?).to be false

    @paste.highlighted = false
    expect(@paste.highlighted?).to be false
  end

  it 'should not be valid if content is blank' do
    @paste.content = nil
    expect(@paste).not_to be_valid

    @paste.content = ''
    expect(@paste).not_to be_valid
  end

  it 'should be valid if content is defined' do
    expect(@paste).to be_valid
  end

  it 'should not be owned by nil' do
    expect(@paste.owner?(nil)).to be false
  end

  it 'should be owned by a user' do
    user = User.create(
      name: 'Test User',
      username: 'test',
      email: 'test@example.com',
      password: 'password',
      password_confirmation: 'password',
    )
    @paste.user = user
    expect(@paste.owner?(user)).to be true
  end

  it 'should increment the view count' do
    expect(@paste.view_count).to eq(0)
    @paste.increment_view_count
    expect(@paste.view_count).to eq(1)
  end

  it 'should have a created_at date' do
    expect(@paste.created_at).to be_a(Time)
  end

  it 'should have a updated_at date' do
    @paste.content = 'Something different ...'
    @paste.save
    expect(@paste.updated_at).to be_a(Time)
  end

  it 'should expire if is a one_time paste' do
    expect(@paste.expired?).to be false
    @paste.one_time = true
    @paste.increment_view_count
    @paste.increment_view_count
    expect(@paste.expired?).to be true
  end

  it 'should not expire if is not a one_time paste' do
    expect(@paste.expired?).to be false
    @paste.increment_view_count
    expect(@paste.expired?).to be false
  end

  it 'should expire if an expiration date is set' do
    expect(@paste.expired?).to be false
    @paste.expires_at = Time.now - 60
    expect(@paste.expired?).to be true
  end

  it 'should validate the expires value' do
    @paste.expires = -1
    expect(@paste).to be_valid
    @paste.expires = 0
    expect(@paste).to be_valid
    @paste.expires = 3600
    expect(@paste).to be_valid
    @paste.expires = 86400
    expect(@paste).to be_valid
    @paste.expires = 604800
    expect(@paste).to be_valid
    @paste.expires = 2592000
    expect(@paste).to be_valid
    @paste.expires = 1234
    expect(@paste).not_to be_valid
  end

  it 'should set the expiration date' do
    @paste.expires = -1
    expect(@paste.one_time?).to be true
    @paste.expires = 0
    expect(@paste.expires_at).to be nil
    @paste.expires = 3600
    expect(@paste.expires_at).to be_a(Time)
    @paste.expires = 2592000
    expect(@paste.expires_at).to be_a(Time)
    @paste.expires = 2592001
    expect(@paste.expires_at).to be_nil
    @paste.expires = 'string'
    expect(@paste.expires_at).to be_nil
  end
end

describe Paste do
  subject { Paste }

  it { is_expected.to respond_to(:recent) }

  it 'should clean up expired pastes.' do
    expect(Paste.first).to be_nil
    # Create a paste that never expires.
    paste = Paste.create(
      filename: 'test.txt',
      highlighted: true,
      ip_addr: '127.0.0.1',
      content: 'Testing ... 1 ... 2 ... 3',
    )
    expect(Paste.first).not_to be_nil
    # Create a paste that expires on next view.
    Paste.create(
      filename: 'test.txt',
      highlighted: true,
      ip_addr: '127.0.0.1',
      content: 'Testing ... 1 ... 2 ... 3',
      one_time: true,
      view_count: 2,
    )
    # Create a paste that has already expired (time).
    Paste.create(
      filename: 'test.txt',
      highlighted: true,
      ip_addr: '127.0.0.1',
      content: 'Testing ... 1 ... 2 ... 3',
      expires_at: Time.now - 3600,
    )
    expect(Paste.count).to eq(3)
    Paste.remove_expired
    expect(Paste.count).to eq(1)
    expect(Paste.first.id).to eq(paste.id)
  end
end
