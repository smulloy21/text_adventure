require('spec_helper')

describe(User) do
  it { should have_many(:characters) }
  it { should have_many(:quests) }
end
