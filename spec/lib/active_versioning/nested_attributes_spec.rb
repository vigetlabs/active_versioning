require 'spec_helper'

RSpec.describe ActiveVersioning::Model::Versioned do
  let!(:post) do
    ActiveVersioning::Test::Post.create(
      title: 'So Post',
      body: 'Such interesting. Very wow.'
    ) 
  end

  let!(:committed_at) { Time.utc(2014, 11, 26, 12, 42, 35) }

  describe "assigning nested attributes" do
    let(:subject) { post.current_draft }

    it "creates a new belongs-to relationship" do
      expect {
        subject.assign_attributes(author_attributes: { name: "Steve" })
        subject.save
      }.not_to change {
        ActiveVersioning::Test::User.count
      }

      p = ActiveVersioning::Test::Post.find(post.id).current_draft

      expect { p.commit }.to change { ActiveVersioning::Test::User.count }.by(1)
    end

    it "updates an existing belongs-to relationship" do
      subject.assign_attributes(author_attributes: { name: "Steve" })
      subject.save
      subject.commit

      p = ActiveVersioning::Test::Post.find(post.id).current_draft

      p.assign_attributes(author_attributes: { id: p.author.id, name: "Steeve" })
      p.save

      p = ActiveVersioning::Test::Post.find(post.id).current_draft

      expect {
        p.commit
      }.to change {
        ActiveVersioning::Test::User.first.name
      }.from("Steve").to("Steeve")
    end
  end
end
