require 'spec_helper'

RSpec.describe ActiveVersioning::Model do
  let!(:post)         { ActiveVersioning::Test::Post.create(title: 'So Post', body: 'Such interesting.  Very wow.') }
  let!(:committed_at) { Time.utc(2014, 11, 26, 12, 42, 35) }

  subject do
    ActiveVersioning::Test::Version.create(
      versionable:  post,
      object:       { 'title' => 'Boom Pow' },
      committed_at: committed_at
    )
  end

  it { should belong_to(:versionable) }

  it { should serialize(:object).as(Hash) }

  it { should validate_presence_of(:event) }
  it { should validate_inclusion_of(:event).in_array(ActiveVersioning::Events::ALL) }

  describe "#to_s" do
    it { expect(subject.to_s).to match(/^#{post.to_s}/) }
    it { expect(subject.to_s).to match(/20141126124235$/) }
  end

  describe "#reify" do
    context "with a valid object" do
      let!(:version) { subject.reify }

      it "returns a different Ruby object than versionable" do
        expect(version.object_id).to_not eq(subject.versionable.object_id)
      end

      it "assigns old version's attributes" do
        expect(version.title).to eq('Boom Pow')
        expect(version.body).to eq('Such interesting.  Very wow.')
      end
    end

    context "with an object containing unknown attributes" do
      let!(:version) do
        ActiveVersioning::Test::Version.create(
          event:       'commit',
          versionable: post,
          object:      { 'title' => 'Ruh Roh', 'rating' => '4 Stars' },
        )
      end

      it "doesn't raise an unknown attribute error" do
        expect {
          version.reify
        }.not_to raise_error
      end
    end
  end
end
