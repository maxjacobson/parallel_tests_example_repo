require "rails_helper"

describe "HELLO" do
  it "is 2" do
    expect(ENV["HELLO"]).to eq "2"
  end
end
