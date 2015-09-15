require 'spec_helper'

RSpec.describe ActiveVersioning::VersionManager do
  let!(:post) { ActiveVersioning::Test::Post.create(title: 'So Post', body: 'Such interesting.  Very wow.') }

  let!(:incompatible_version) do
    ActiveVersioning::Test::Version.create(
      event:       'commit',
      versionable: post,
      object:      { 'title' => 'Ruh Roh', 'rating' => '4 Stars' },
    )
  end

  subject { described_class.new(post) }

  describe "#create_draft_from_version" do
    context "when there are incompatible attributes in the given version" do
      it "raises an error" do
        expect {
          subject.create_draft_from_version(incompatible_version.id)
        }.to raise_error(ActiveVersioning::Errors::IncompatibleVersion)
      end

      it "raises an error object with the original record and the offending version" do
        begin
          subject.create_draft_from_version(incompatible_version.id)
        rescue ActiveVersioning::Errors::IncompatibleVersion => error
          expect(error.message).to eq 'The given version contains attributes that are no longer compatible with the current schema: rating.'
          expect(error.record).to eq post
          expect(error.version).to eq incompatible_version
        end
      end
    end
  end

  describe "#incompatible_attributes" do
    it { expect(subject.incompatible_attributes(incompatible_version)).to eq ['rating'] }
  end
end
