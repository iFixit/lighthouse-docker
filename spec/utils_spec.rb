require 'utils'

RSpec.describe ExecHelpers, '#limited_system' do
  ExecHelpers::LIGHTHOUSE_TIMEOUT = 1
  it "returns false if the command fails" do
    expect(ExecHelpers.limited_system('false')).to be false
  end

  it "returns true if the command succeeds" do
    expect(ExecHelpers.limited_system('true')).to be true
  end
end
