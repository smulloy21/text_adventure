require('spec_helper')

describe(Quest) do
  it { should have_many(:scenes) }
  it { should belong_to(:user)}
end
