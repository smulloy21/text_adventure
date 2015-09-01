require('spec_helper')

describe(Character) do
  it { should belong_to(:user) }
  it { should have_many(:quests) }
end
