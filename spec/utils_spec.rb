require 'utils'

RSpec.describe ExecHelpers, '#limited_system' do
  ExecHelpers::LIGHTHOUSE_TIMEOUT = 1
  it "returns false if the command fails" do
    expect(ExecHelpers.limited_system('false')).to be false
  end
end
