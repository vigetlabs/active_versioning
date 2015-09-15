require 'spec_helper'

RSpec.describe ActiveVersioning::Model::VersionProxy do
  let!(:post)    { ActiveVersioning::Test::Post.create(title: 'So Post', body: 'Such interesting.  Very wow.') }
  let!(:version) { post.current_draft.version }

  subject { described_class.new(version) }

  describe "#__getobj__" do
    it { expect(subject.__getobj__).to eq post }
  end

  describe "#class" do
    it { expect(subject.class).to eq ActiveVersioning::Test::Post }
  end

  describe "#reload" do
    before { subject }

    it "reifies the version" do
      expect(version).to receive(:reify)

      subject.reload
    end
  end

  describe "#to_param" do
    it { expect(subject.to_param).to eq post.id.to_s }
  end

  describe "#save" do
    context "given valid attributes" do
      before do
        subject.title = 'Test'
        subject.body  = 'New body'
      end

      it "updates the version" do
        subject.save

        expect(subject.reload.title).to eq 'Test'
        expect(subject.body).to eq 'New body'
      end
    end

    context "given invalid attributes" do
      before do
        subject.title = ''
      end

      it "does not update the version" do
        subject.save

        expect(subject.reload.title).to eq 'So Post'
      end
    end
  end

  describe "#save!" do
    context "given valid attributes" do
      before do
        subject.title = 'Test'
        subject.body  = 'New body'
      end

      it "updates the version" do
        subject.save!

        expect(subject.reload.title).to eq 'Test'
        expect(subject.body).to eq 'New body'
      end
    end

    context "given invalid attributes" do
      before do
        subject.title = ''
      end

      it "does not update the version and raises an error" do
        expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid)

        expect(subject.reload.title).to eq 'So Post'
      end
    end
  end

  describe "#update" do
    context "given valid attributes" do
      it "updates the version" do
        subject.update(title: 'Test', body: 'New body')

        expect(subject.reload.title).to eq 'Test'
        expect(subject.body).to eq 'New body'
      end
    end

    context "given invalid attributes" do
      it "does not update the version" do
        subject.update(title: '')

        expect(subject.reload.title).to eq 'So Post'
      end
    end
  end

  describe "#update!" do
    context "given valid attributes" do
      it "updates the version" do
        subject.update!(title: 'Test', body: 'New body')

        expect(subject.reload.title).to eq 'Test'
        expect(subject.body).to eq 'New body'
      end
    end

    context "given invalid attributes" do
      it "does not update the version and raises an error" do
        expect { subject.update!(title: '') }.to raise_error(ActiveRecord::RecordInvalid)

        expect(subject.reload.title).to eq 'So Post'
      end
    end
  end

  describe "#live?" do
    it { expect(subject.live?).to eq false }
  end

  describe "#version?" do
    it { expect(subject.version?).to eq true }
  end

  describe "#commit" do
    before do
      subject.title = 'Test'
    end

    it "updates the version, commits it, and updates the versioned record" do
      subject.commit(commit_message: 'Update post name.')

      expect(version.reload.draft).to eq false
      expect(version.event).to eq ActiveVersioning::Events::COMMIT
      expect(version.commit_message).to eq 'Update post name.'
      expect(post.reload.title).to eq 'Test'
    end

    context "when the underlying version is not a draft" do
      subject { described_class.new(post.versions.committed.first) }

      it "raises an error" do
        expect { subject.commit }.to raise_error(ActiveVersioning::Errors::InvalidVersion)
      end
    end
  end
end
