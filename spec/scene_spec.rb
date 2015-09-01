require('spec_helper')

describe(Scene) do
  it { should belong_to(:quest) }
  it { should have_many(:observations)}
end
