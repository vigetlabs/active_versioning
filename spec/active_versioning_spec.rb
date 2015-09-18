require 'spec_helper'

describe ActiveVersioning do
  it "has a version number" do
    expect(ActiveVersioning::VERSION).to_not be_nil
  end

  describe ".versioned_models" do
    it "eager loads the Rails app unless it's already configured to" do
      expect(Rails.application).to receive(:eager_load!)

      ActiveVersioning.versioned_models
    end

    it { expect(ActiveVersioning.versioned_models).to eq [ActiveVersioning::Test::Post] }
  end
end
