require('spec_helper')

describe(Character) do
  it { should belong_to(:user) }
end
