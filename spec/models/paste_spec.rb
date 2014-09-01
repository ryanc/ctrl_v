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
end

describe Paste do
  subject { Paste }

  it { is_expected.to respond_to(:recent) }
end
