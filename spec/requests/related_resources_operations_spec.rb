require 'spec_helper'

RSpec.describe 'Related resources operations', type: :request do
  fixtures :all

  let(:article) { Article.all.sample }
  let(:authorizations) { {} }
  let(:json_data) { JSON.parse(last_response.body)["data"] }

  before do
    header 'Content-Type', 'application/vnd.api+json'
  end

  describe 'GET /articles/:id/comments' do
    subject(:last_response) { get("/articles/#{article.external_id}/comments") }
    let(:article) { articles(:article_with_comments) }
    let(:comments_on_article) { article.comments }
    let(:comments_class) { comments_on_article.first.class }

    context 'unauthorized for show_related_resources' do
      let(:forbidden_policy) { { forbidden: { action: :index, klass: "Comment" } } }

      before {
        header 'POLICY', forbidden_policy
      }

      it { is_expected.to be_forbidden }
    end

    context 'authorized for show_related_resources' do
      let(:comments_policy_scope) { comments_on_article.limit(1) }
      let(:valid_policy) {
        { scope: { title: :by_article_first_comment_id, article_id: article.external_id, comment_id: comments_policy_scope.first.id } }
      }
      before {
        header 'POLICY', valid_policy
      }

      it { is_expected.to be_ok }

      # If this happens in real life, it's mostly a bug. We want to document the
      # behaviour in that case anyway, as it might be surprising.
      context 'limited by policy scope' do
        let(:valid_policy) {
          { scope: { title: :by_article_not_found, article_id: article.external_id } }
        }
        before {
          header 'POLICY', valid_policy
        }

        it { is_expected.to be_not_found }
      end

      it 'displays only comments allowed by CommentPolicy::Scope' do
        expect(json_data.length).to eq(1)
        expect(json_data.first["id"]).to eq(comments_policy_scope.first.id.to_s)
      end
    end
  end

  describe 'GET /articles/:id/author' do
    subject(:last_response) { get("/articles/#{article.external_id}/author") }
    let(:article) { articles(:article_with_author) }

    context 'unauthorized for show_related_resource' do
      let(:forbidden_policy) { { forbidden: { action: :show, klass: "User" } } }

      before {
        header 'POLICY', forbidden_policy
      }

      it { is_expected.to be_forbidden }
    end

    context 'authorized for show_related_resource' do
      it { is_expected.to be_successful }

      # If this happens in real life, it's mostly a bug. We want to document the
      # behaviour in that case anyway, as it might be surprising.
      context 'limited by policy scope' do
        let(:valid_policy) {
          { scope: { title: :by_article_not_found, article_id: article.external_id } }
        }
        before {
          header 'POLICY', valid_policy
        }

        it { is_expected.to be_not_found }
      end
    end
  end
end
