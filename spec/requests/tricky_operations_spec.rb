require 'spec_helper'

RSpec.describe 'Tricky operations', type: :request do
  # include AuthorizationStubs
  fixtures :all

  let(:article) { Article.all.sample }
  # let(:policy_scope) { Article.none }

  subject { last_response }
  let(:json_data) { JSON.parse(last_response.body)["data"] }

  # before do
  #   allow_any_instance_of(ArticlePolicy::Scope).to receive(:resolve).and_return(policy_scope)
  # end

  before do
    header 'Content-Type', 'application/vnd.api+json'
  end

  describe 'POST /comments (with relationships link to articles)' do
    subject(:last_response) { post("/comments", json) }
    let(:json) do
      <<-EOS.strip_heredoc
      {
        "data": {
          "type": "comments",
          "relationships": {
            "article": {
              "data": {
                "id": "#{article.external_id}",
                "type": "articles"
              }
            }
          }
        }
      }
      EOS
    end

    context 'authorized for create_resource on Comment and newly associated article' do
      it { is_expected.to be_successful }
    end

    context 'unauthorized for create_resource on Comment and newly associated article' do
      let(:forbidden_policy) { { forbidden: { action: :create, klass: "Comment" } } }

      before {
        header 'POLICY', forbidden_policy
      }

      it { is_expected.to be_forbidden }

      context 'which is out of scope' do
        let(:article_not_found_policy) {
          { scope: { title: :by_article_not_found, article_id: article.external_id } }
        }
        before {
          header 'POLICY', article_not_found_policy
        }

        it { is_expected.to be_not_found }
      end
    end
  end

  describe 'POST /articles (with relationships link to comments)' do
    let!(:new_comments) do
      Array.new(2) { Comment.create }
    end
    let(:json) do
      <<-EOS.strip_heredoc
      {
        "data": {
          "id": "new-article-id",
          "type": "articles",
          "relationships": {
            "comments": {
              "data": [
                { "id": "#{new_comments[0].id}", "type": "comments" },
                { "id": "#{new_comments[1].id}", "type": "comments" }
              ]
            }
          }
        }
      }
      EOS
    end
    subject(:last_response) { post("/articles", json) }

    context 'authorized for create_resource on Article and newly associated comments' do
      it { is_expected.to be_successful }
    end

    context 'unauthorized for create_resource on Article and newly associated comments' do
      let(:policy_scope) { Article.where(id: "new-article-id") }

      let(:forbidden_policy) { { forbidden: { action: :create, klass: "Article" } } }

      before {
        header 'POLICY', forbidden_policy
      }

      it { is_expected.to be_forbidden }
    end
  end

  describe 'POST /tags (with polymorphic relationship link to article)' do
    subject(:last_response) { post("/tags", json) }
    let(:json) do
      <<-EOS.strip_heredoc
      {
        "data": {
          "type": "tags",
          "relationships": {
            "taggable": {
              "data": {
                "id": "#{article.external_id}",
                "type": "Article"
              }
            }
          }
        }
      }
      EOS
    end

    context 'authorized for create_resource on Tag and newly associated article' do
      it { is_expected.to be_successful }
    end

    context 'unauthorized for create_resource on Tag and newly associated article' do
      let(:forbidden_policy) { { forbidden: { action: :create, klass: "Tag" } } }

      before {
        header 'POLICY', forbidden_policy
      }

      it { is_expected.to be_forbidden }

      context 'which is out of scope' do
        let(:article_not_found_policy) {
          { scope: { title: :by_article_not_found, article_id: article.external_id } }
        }
        before {
          header 'POLICY', article_not_found_policy
        }

        it { is_expected.to be_not_found }
      end
    end
  end

  describe 'PATCH /articles/:id (mass-modifying relationships)' do
    let!(:new_comments) do
      Array.new(2) { Comment.create }
    end

    let(:json) do
      <<-EOS.strip_heredoc
      {
        "data": {
          "id": "#{article.external_id}",
          "type": "articles",
          "relationships": {
            "comments": {
              "data": [
                { "type": "comments", "id": "#{new_comments.first.id}" },
                { "type": "comments", "id": "#{new_comments.second.id}" }
              ]
            }
          }
        }
      }
      EOS
    end
    subject(:last_response) { patch("/articles/#{article.external_id}", json) }

    context 'authorized for replace_fields on article and all new records' do
      context 'not limited by Comments policy scope' do
        it { is_expected.to be_successful }
      end

      context 'limited by Comments policy scope' do
        let(:comments_not_found_policy) {
          { scope: { title: :by_comments_not_found, article_id: article.external_id, comment_ids: new_comments.pluck(:id) } }
        }
        before {
          header 'POLICY', comments_not_found_policy
        }

        it { is_expected.to be_not_found }
      end
    end

    context 'unauthorized for replace_fields on article and all new records' do
      let(:forbidden_policy) { { forbidden: { action: :create, klass: "Article" } } }

      before {
        header 'POLICY', forbidden_policy
      }

      it { is_expected.to be_forbidden }
    end
  end

  describe 'PATCH /articles/:id (nullifying to-one relationship)' do
    let(:article) { articles(:article_with_author) }
    let(:json) do
      <<-EOS.strip_heredoc
      {
        "data": {
          "id": "#{article.external_id}",
          "type": "articles",
          "relationships": { "author": null }
        }
      }
      EOS
    end
    subject(:last_response) { patch("/articles/#{article.external_id}", json) }

    it { is_expected.to be_successful }
  end
end
