# Create a user
puts "<= creating sample user"
user = Models::User.create(
  :name => 'Demo User',
  :username => 'demo',
  :email => 'demo@example.net',
  :password => 'demo',
  :password_confirmation => 'demo',
)

# Create a paste
puts "<= creating sample paste"
paste = Models::Paste.create(
  :filename => "file.txt",
  :highlight => false,
  :content => Models::Content.create(:content => "Hello :)"),
  :user_id => 1,
)
paste = Models::Paste.create(
  :filename => "file.txt",
  :highlight => false,
  :content => Models::Content.create(:content => "Hello again :)"),
)
