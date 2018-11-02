require 'spec_helper'

RSpec.describe ActiveVersioning::Model::Versioned do
  let!(:user) { ActiveVersioning::Test::User.create(name: 'Bo Janglez', email: 'bo.janglez@gmail.com') }

  subject { ActiveVersioning::Test::Post.create(title: 'So Post', body: 'Such interesting.  Very wow.', user: user) }

  it { should have_many(:versions) }

  describe "after create" do
    it "creates a new version" do
      expect {
        ActiveVersioning::Test::Post.create(title: 'So Post', body: 'Such interesting.  Very wow.', user: user, version_author: user)
      }.to change { ActiveVersioning::Test::Version.count }.by 1
    end
  end

  describe "#version_author" do
    it "should be able to set and view the author" do
      subject.version_author = user

      expect(subject.version_author).to eq user
    end
  end

  describe "#live?" do
    it { expect(subject.live?).to eq true }
  end

  describe "#version?" do
    it { expect(subject.version?).to eq false }
  end

  describe "#current_draft" do
    context "when the record is not persisted" do
      subject { ActiveVersioning::Test::Post.new }

      it "raises an error" do
        expect { subject.current_draft }.to raise_error(ActiveVersioning::Errors::RecordNotPersisted)
      end
    end

    context "when there are no draft versions" do
      it "creates a new draft version wrapped in a VersionProxy" do
        expect {
          subject.current_draft

          # Verify we have a VersionProxy
          expect(subject.current_draft.__getobj__).to eq subject
        }.to change { subject.versions.count }.by 1
      end
    end

    context "when there are existing draft versions" do
      let!(:draft) { subject.current_draft }

      it "grabs the first draft version and wraps it in a VersionProxy" do
        expect {
          expect(subject.current_draft).to eq draft

          # Verify we have a VersionProxy
          expect(draft.__getobj__).to eq subject
        }.to_not change { subject.versions.count }
      end
    end

    it "is not live" do
      expect(subject.current_draft.live?).to eq false
    end

    it "is a version" do
      expect(subject.current_draft.version?).to eq true
    end
  end

  describe "#current_draft?" do
    context "when the record has a draft version" do
      before { subject.current_draft(true) }

      it { expect(subject.current_draft?).to eq true }
    end

    context "when the record does not have a draft version" do
      it { expect(subject.current_draft?).to eq false }
    end
  end

  describe "#destroy_draft" do
    before { subject.current_draft(true) }

    it "destroys all draft versions" do
      expect { subject.destroy_draft }.to change { subject.current_draft? }.from(true).to(false)
    end
  end

  describe "#create_draft_from_version" do
    let!(:version) do
      subject.versions.committed.create(
        event:  ActiveVersioning::Events::COMMIT,
        object: { 'title' => 'Random Title', 'body' => 'Random body text.' }
      )
    end

    it "creates a new draft from the given version" do
      expect {
        subject.create_draft_from_version(version.id)
      }.to change { subject.versions.count }.by 1
    end

    it "creates a new draft with the same object as the given version" do
      subject.create_draft_from_version(version.id)

      expect(subject.current_draft.title).to eq 'Random Title'
      expect(subject.current_draft.body).to eq 'Random body text.'
    end
  end

  describe "#versioned_attributes" do
    let(:test_post) { ActiveVersioning::Test::Post.create(
        title: 'So Post',
        body: 'Such interesting.  Very wow.',
        author_attributes: {
          name: 'This should work',
          email: 'working@example.com'
        }
      )
    }

    it "returns a hash of the attributes and their values" do
      expect(subject.versioned_attributes).to eq(
        'id'      => subject.id,
        'title'   => 'So Post',
        'body'    => 'Such interesting.  Very wow.',
        'user_id' => user.id,
        'author_attributes'  => {
          'id' => user.id,
          'name' => user.name,
          'email' => user.email
        }
      )
    end

    it "allows nested_attributes_for to work with creates" do
      attrs = test_post.versioned_attributes['author_attributes']

      expect(attrs['name']).to eq('This should work')
      expect(attrs['email']).to eq('working@example.com')
    end

    it "allows nested_attributes_for to work with updates" do
      test_post.update(
        author_attributes: {
          name: 'This should work',
          email: 'working@example.com'
        }
      )

      attrs = test_post.versioned_attributes['author_attributes']
      expect(attrs['name']).to eq('This should work')
      expect(attrs['email']).to eq('working@example.com')
    end
  end

  describe "#versioned_attribute_names" do
    it { expect(subject.versioned_attribute_names).to match_array %w(title body id user_id) }
  end

  describe "#versioned_nested_attribute_names" do
    it { expect(subject.versioned_nested_attribute_names).to match_array %w(author) }
  end
end
