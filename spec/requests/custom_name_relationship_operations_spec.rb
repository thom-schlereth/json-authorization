require 'spec_helper'

RSpec.describe 'including custom name relationships', type: :request do
  fixtures :all

  subject { last_response }
  let(:json_included) { JSON.parse(last_response.body) }

  before do
    header 'Content-Type', 'application/vnd.api+json'
  end

  describe 'GET /comments/:id/reviewer' do
    subject(:last_response) { get("/comments/#{Comment.first.id}/reviewer") }
    context "access authorized" do
      it { is_expected.to be_ok }
    end

    context "access to reviewer forbidden" do
      let(:forbidden_policy) { { forbidden: { action: :show, klass: "User" } } }

      before {
        header 'POLICY', forbidden_policy
      }

      it { is_expected.to be_forbidden }
    end
  end
end
