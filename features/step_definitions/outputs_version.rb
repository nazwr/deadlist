require './lib/deadlist'

Given("DeadList is initialized") do
  @deadlist = DeadList.new
end

When("the --version method is called") do
  @version = @deadlist.current_version
end

Then('a semantic version v1.X.X etc. should be output') do
  expect(@version).to eq(@deadlist.current_version)
end
