describe User do
  before do
    @user = User.create(
      name: 'Test User',
      username: 'test',
      email: 'test@example.com',
      password: 'password',
      password_confirmation: 'password',
    )
  end

  subject { @user }

  it { is_expected.to respond_to(:id) }
  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:username) }
  it { is_expected.to respond_to(:email) }
  it { is_expected.to respond_to(:password_hash) }
  it { is_expected.to respond_to(:created_at) }
  it { is_expected.to respond_to(:last_seen_at) }
  it { is_expected.to respond_to(:updated_at) }
  it { is_expected.to respond_to(:activation_token) }
  it { is_expected.to respond_to(:active) }
  it { is_expected.to respond_to(:password_reset_token) }
  it { is_expected.to respond_to(:password_reset_token_generated_at) }
  it { is_expected.to respond_to(:authenticate) }
  it { is_expected.to respond_to(:generate_password_reset_token) }
  it { is_expected.to respond_to(:password_reset_token_expired?) }
  it { is_expected.to respond_to(:clear_password_reset_token) }
  it { is_expected.to respond_to(:password) }
  it { is_expected.to respond_to(:password_confirmation) }

  it 'should authenticate successfully' do
    expect(@user.authenticate('password')).to be true
  end

  it 'should authenticate unsuccessfully' do
    expect(@user.authenticate('wrong_password')).to be false
  end

  it 'should have a created_at date' do
    expect(@user.created_at).to be_a(Time)
  end

  it 'should have a last_seen_at date' do
    @user.last_seen_at = Time.now
    expect(@user.last_seen_at).to be_a(Time)
  end

  it 'should have a updated_at date' do
    @user.name = 'Test User'
    @user.save
    expect(@user.updated_at).to be_a(Time)
  end

  it 'should be invalid if the username is blank' do
    @user.username = ''
    expect(@user).not_to be_valid
    expect(@user.errors[:username]).to include('The username cannot be blank.')

    @user.username = nil
    expect(@user).not_to be_valid
    expect(@user.errors[:username]).to include('The username cannot be blank.')
  end

  it 'should be invalid if the email is blank' do
    @user.email = ''
    expect(@user).not_to be_valid
    expect(@user.errors[:email]).to include('The email address cannot be blank.')

    @user.email = nil
    expect(@user).not_to be_valid
    expect(@user.errors[:email]).to include('The email address cannot be blank.')
  end

  it 'should be invalid if the password is blank' do
    @user = User.new(
      name: 'Test User',
      username: 'test',
      email: 'test@example.com',
    )

    @user.password = ''
    expect(@user).not_to be_valid
    expect(@user.errors[:password]).to include('The password cannot be blank.')

    @user.password = nil
    expect(@user).not_to be_valid
    expect(@user.errors[:password]).to include('The password cannot be blank.')
  end

  it 'should be invalid if the password is not confirmed' do
    user = User.new(
      name: 'Test User',
      username: 'test2',
      email: 'test2@example.com',
    )

    user.password = 'password'
    expect(user).not_to be_valid
    expect(user.errors[:password_confirmation]).to include('The password confirmation cannot be blank.')

    user.password_confirmation = 'wrong_password'
    expect(user).not_to be_valid
    expect(user.errors[:password_confirmation]).to include('The passwords must match.')

    user.password_confirmation = 'password'
    expect(user).to be_valid
  end

  it 'should be invalid if the username is not unique' do
    user = User.new(
      name: 'Test User',
      username: 'test',
      email: 'test2@example.com',
      password: 'password',
      password_confirmation: 'password',
    )
    expect(user).not_to be_valid
    expect(user.errors[:username]).to include('The username is already taken.')
  end

  it 'should be invalid if the email is not unique' do
    user = User.new(
      name: 'Test User',
      username: 'test2',
      email: 'test@example.com',
      password: 'password',
      password_confirmation: 'password',
    )
    expect(user).not_to be_valid
    expect(user.errors[:email]).to include('The email address has already been used.')
  end

  it 'should generate an activation token' do
    expect(@user.activation_token).not_to be nil
  end

  it 'should generate a password reset token' do
    expect(@user.password_reset_token).to be nil
    @user.generate_password_reset_token
    expect(@user.password_reset_token).not_to be nil
  end

  it 'should detect an expired password reset token' do
    @user.generate_password_reset_token
    expect(@user.password_reset_token_expired?).to be false

    @user.password_reset_token_generated_at = Time.new - 1800
    expect(@user.password_reset_token_expired?).to be true
  end

  it 'should clear the password reset token' do
    expect(@user.password_reset_token).to be nil
    @user.generate_password_reset_token
    expect(@user.password_reset_token).not_to be nil
    @user.clear_password_reset_token
    expect(@user.password_reset_token).to be nil
  end
end
