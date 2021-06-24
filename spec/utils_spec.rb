require 'utils'

RSpec.describe ExecHelpers, '#limited_system' do
  it "returns false if the command fails" do
    expect(ExecHelpers.limited_system('false')).to be false
  end

  it "returns true if the command succeeds" do
    expect(ExecHelpers.limited_system('true')).to be true
  end

  it "times out slow commands" do
    ExecHelpers::Log.level = Logger::ERROR
    ExecHelpers.lighthouse_timeout = 0.1
    expect(ExecHelpers.limited_system('sleep', '10')).to be false
  end
end
