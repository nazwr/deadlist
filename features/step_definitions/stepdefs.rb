require './lib/deadlist.rb'

Given("DeadList is initialized") do
  @deadlist = DeadList.new
end

When("the --version method is called") do
  @version = @deadlist.version
end

Then('a semantic version v1.X.X etc. should be output') do
  expect(@version).to eq('v1.0.0')
end