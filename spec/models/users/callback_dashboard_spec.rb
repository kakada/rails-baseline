# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::CallbackDashboard, type: :model do
  describe "after_create, add_to_dashboard" do
    context "create new user and have confirmed" do
      let(:user) { create(:user) }

      before {
        allow(user).to receive(:unallow_access_dashboard?).and_return false
      }

      it "adds an job to UserJob" do
        expect {
          user.update(confirmed_at: Time.now)
        }.to change(UserJob.jobs, :count)
      end

      it "adds the user to dashboard" do
        create(:user, :allow_callback)

        expect(UserJob.jobs.last["args"][0]).to eq("add_to_dashboard")
      end
    end
  end

  describe "#after_update, add_to_dashboard" do
    context "user set to confirmed" do
      let(:user) { create(:user) }

      before {
        user.update(confirmed_at: nil, skip_callback: false)

        allow(user).to receive(:unallow_access_dashboard?).and_return false
      }

      it "adds the user to dashboard" do
        user.update(confirmed_at: Time.now)
        expect(UserJob.jobs.last["args"][0]).to eq("add_to_dashboard")
      end

      it "adds an job to UserJob" do
        expect {
          user.update(confirmed_at: Time.now)
        }.to change(UserJob.jobs, :count)
      end
    end

    context "deactivate user" do
      let!(:user) { create(:user, gf_user_id: 1) }

      before do
        allow(user).to receive(:unallow_access_dashboard?).and_return false
      end

      it "adds a job to UserJob" do
        expect {
          user.update(actived: false)
        }.to change(UserJob.jobs, :count)
      end

      it "remove user from the dashboard" do
        user.update(actived: false)

        expect(UserJob.jobs.last["args"][0]).to eq("remove_from_dashboard")
      end
    end

    context "activate user" do
      let!(:user) { create(:user, actived: false) }

      before do
        allow(user).to receive(:unallow_access_dashboard?).and_return false
      end

      it "adds a job to UserJob" do
        expect {
          user.update(actived: true)
        }.to change(UserJob.jobs, :count)
      end

      it "remove user from the dashboard" do
        user.update(actived: true)

        expect(UserJob.jobs.last["args"][0]).to eq("add_to_dashboard")
      end
    end
  end

  describe "#unallow_access_dashboard?" do
    context "skip_callback is true" do
      let(:user) { build(:user, skip_callback: true) }

      before do
        stub_const('ENV', ENV.to_hash.merge('GF_DASHBOARD_URL' => 'http://localhost:8000'))
      end

      it "returns true" do
        expect(user.send('unallow_access_dashboard?')).to be_truthy
      end
    end

    context "environment variable GF_DASHBOARD_URL is blank" do
      let(:user) { build(:user, :allow_callback) }

      before do
        stub_const('ENV', ENV.to_hash.merge('GF_DASHBOARD_URL' => ''))
      end

      it "returns true" do
        expect(user.send('unallow_access_dashboard?')).to be_truthy
      end
    end

    context "allow_callback, has_dashboad_url" do
      let(:user) { build(:user, :allow_callback) }

      before do
        stub_const('ENV', ENV.to_hash.merge('GF_DASHBOARD_URL' => 'http://localhost:8000'))
      end

      it "returns false" do
        expect(user.send('unallow_access_dashboard?')).to be_falsey
      end
    end
  end
end
