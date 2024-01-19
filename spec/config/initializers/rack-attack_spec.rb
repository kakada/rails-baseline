require "rails_helper"

describe Rack::Attack do
  include Rack::Test::Methods

  def app
    Rails.application
  end

  let(:limit) { 5 }

  describe "request from localhost" do
    it "returns ok" do
      within_same_period do
        (limit + 1).times { |i| post "/sign_in", { email: "example#{i}@gmail.com" }, "REMOTE_ADDR" => "127.0.0.1" }
      end

      expect(last_response.status).to eq(200)
    end
  end

  describe "throttle excessive POST requests to user sign in by IP address" do
    context "number of requests is lower than the limit" do
      it "does not change the request status" do
        within_same_period do
          (limit - 1).times { |i| post "/sign_in", { email: "example#{i}@gmail.com" }, "REMOTE_ADDR" => "1.2.3.7" }
        end

        expect(last_response.status).to_not eq(503)
      end
    end

    context "number of user requests is higher than the limit" do
      it "changes the request status to 503" do
        within_same_period do
          (limit + 1).times { |i| post "/sign_in", { email: "example#{i}@gmail.com" }, "REMOTE_ADDR" => "1.2.3.9" }
        end

        expect(last_response.status).to eq(503)
      end
    end
  end

  describe "throttle excessive POST requests to user sign in by email address" do
    context "number of requests is lower than the limit" do
      it "does not change the request status" do
        within_same_period do
          (limit - 1).times { |i| post "/sign_in", { email: "example8@gmail.com" }, "REMOTE_ADDR" => "#{i}.2.3.4" }
        end

        expect(last_response.status).to_not eq(503)
      end
    end

    context "number of requests is higher than the limit" do
      it "changes the request status to 503" do
        within_same_period do
          (limit + 1).times { |i| post "/sign_in", { email: "example8@gmail.com" }, "REMOTE_ADDR" => "#{i}.2.3.4" }
        end

        expect(last_response.status).to eq(503)
      end
    end
  end
end
