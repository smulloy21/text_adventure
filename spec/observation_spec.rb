require('spec_helper')

describe(Observation) do
  it { should belong_to(:scene) }
end
