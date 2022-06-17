require 'spec_helper'

RSpec.describe 'including resources alongside normal operations', type: :request do
  fixtures :all

  subject { last_response }
  let(:json_included) { JSON.parse(last_response.body)['included'] }

  before do
    header 'Content-Type', 'application/vnd.api+json'
  end

  shared_examples_for :include_directive_tests do
    describe 'one-level deep has_many relationship' do
      let(:include_query) { 'comments' }

      context 'unauthorized for include_has_many_resource for Comment' do
        let(:forbidden_policy) { { forbidden: { klass: 'Comment', action: :index }} }
        before {
          header 'POLICY', forbidden_policy
        }

        it { is_expected.to be_forbidden }
      end

      context 'authorized for include_has_many_resource for Comment' do
        before {
          header 'POLICY', valid_policy
        }

        it { is_expected.to be_successful }

        it 'includes only comments allowed by policy scope and associated with the article' do

          expect(json_included.length).to eq(article.comments.count)

          expect(
            json_included.map { |included| included["id"].to_i }
          ).to match_array(article.comments.map(&:id))
        end
      end
    end

    describe 'one-level deep has_one relationship' do
      let(:include_query) { 'author' }

      context 'unauthorized for include_has_one_resource for article.author' do

        before {
          header 'POLICY', forbidden_policy
        }

        it { is_expected.to be_forbidden }
      end

      context 'authorized for include_has_one_resource for article.author' do
        before {
          header 'POLICY', valid_policy
        }

        it { is_expected.to be_successful }

        it 'includes the associated author resource' do
          json_users = json_included.select { |i| i['type'] == 'users' }
          expect(json_users).to include(a_hash_including('id' => article.author.id.to_s))
        end
      end
    end

    describe 'multiple one-level deep relationships' do
      let(:include_query) { 'author,comments' }

      context 'unauthorized for include_has_one_resource for article.author' do
        let(:forbidden_policy) {{ forbidden: { action: :show, klass: "User" }}}
        before {
          header 'POLICY', forbidden_policy
        }

        it { is_expected.to be_forbidden }
      end

      context 'unauthorized for include_has_many_resource for Comment' do
        let(:forbidden_policy) {{ forbidden: { action: :index, klass: "Comment" }}}
        before {
          header 'POLICY', forbidden_policy
        }
        it { is_expected.to be_forbidden }
      end

      context 'authorized for both operations' do
        before {
          header 'POLICY', valid_policy
        }

        it { is_expected.to be_successful }

        it 'includes only comments allowed by policy scope and associated with the article' do
          json_comments = json_included.select { |item| item['type'] == 'comments' }
          expect(json_comments.length).to eq(article.comments.count)
          expect(
            json_comments.map { |i| i['id'] }
          ).to match_array(article.comments.pluck(:id).map(&:to_s))
        end

        it 'includes the associated author resource' do
          json_users = json_included.select { |item| item['type'] == 'users' }
          expect(json_users).to include(a_hash_including('id' => article.author.id.to_s))
        end
      end
    end

    describe 'a deep relationship' do
      let(:include_query) { 'author.comments' }

      context 'unauthorized for first relationship' do
        let(:forbidden_policy) {{ forbidden: { action: :show, klass: "User" }}}
        before {
          header 'POLICY', forbidden_policy
        }

        it { is_expected.to be_forbidden }
      end

      context 'authorized for first relationship' do

        context 'unauthorized for second relationship' do
          let(:forbidden_policy) {{ forbidden: { action: :index, klass: "Comment" }}}
          before { header 'POLICY', forbidden_policy }

          it { is_expected.to be_forbidden }
        end

        context 'authorized for second relationship' do
          before { header 'POLICY', valid_policy }

          it { is_expected.to be_successful }

          it 'includes the first level resource' do
            json_users = json_included.select { |item| item['type'] == 'users' }
            expect(json_users).to include(a_hash_including('id' => article.author.id.to_s))
          end

          describe 'second level resources' do
            before { header 'POLICY', create_special_policy || {scope: { title: :by_author_id_for_comment, message: article.author.id }}}

            it 'includes only resources allowed by policy scope' do
              second_level_items = json_included.select { |item| item['type'] == 'comments' }
              expect(second_level_items.length).to eq(article.author.comments.count)
              expect(
                second_level_items.map { |i| i['id'] }
              ).to match_array(article.author.comments.pluck(:id).map(&:to_s))
            end
          end
        end
      end
    end

    describe 'a deep relationship with empty relations' do
      context 'first level has_one is nil' do
        let(:include_query) { 'non-existing-article.comments' }

        before {
          header 'POLICY', {}
        }

        it { is_expected.to be_successful }
      end

      context 'first level has_many is empty' do
        let(:include_query) { 'empty-articles.comments' }

        context 'unauthorized for first relationship' do
          let(:forbidden_policy) {{ forbidden: { action: :index, klass: "Article" }}}
          before {
            header 'POLICY', forbidden_policy
          }

          it { is_expected.to be_forbidden }
        end

        context 'authorized for first relationship' do
          before {
            header 'POLICY', {}
          }
          it { is_expected.to be_successful }
        end
      end
    end
  end

  shared_examples_for :scope_limited_directive_tests do
    before {
      header 'POLICY', { scope: { title: :by_article_first_comment_id, message: article.comments.first.id } }
    }

    describe 'one-level deep has_many relationship' do
      let(:comments_policy_scope) { Comment.where(id: article.comments.first.id) }
      let(:include_query) { 'comments' }

      context 'authorized for include_has_many_resource for Comment' do

        it { is_expected.to be_successful }

        it 'includes only comments allowed by policy scope' do
          expect(json_included.length).to eq(comments_policy_scope.length)
          expect(json_included.first["id"]).to eq(comments_policy_scope.first.id.to_s)
        end
      end
    end

    describe 'multiple one-level deep relationships' do
      let(:include_query) { 'author,comments' }
      let(:comments_policy_scope) { Comment.where(id: article.comments.first.id) }

      context 'authorized for both operations' do
        it { is_expected.to be_successful }

        it 'includes only comments allowed by policy scope and associated with the article' do
          json_comments = json_included.select { |item| item['type'] == 'comments' }
          expect(json_comments.length).to eq(comments_policy_scope.length)
          expect(
            json_comments.map { |i| i['id'] }
          ).to match_array(comments_policy_scope.pluck(:id).map(&:to_s))
        end

        it 'includes the associated author resource' do
          json_users = json_included.select { |item| item['type'] == 'users' }
          expect(json_users).to include(a_hash_including('id' => article.author.id.to_s))
        end
      end
    end

    describe 'a deep relationship' do
      let(:include_query) { 'author.comments' }
      let(:comments_policy_scope) { Comment.where(id: article.author.comments.first.id) }
      before {
        header 'POLICY', { scope: { title: :by_article_first_comment_id, message: article.author.comments.first.id } }
      }

      context 'authorized for first relationship' do
        context 'authorized for second relationship' do
          it { is_expected.to be_successful }

          it 'includes the first level resource' do
            json_users = json_included.select { |item| item['type'] == 'users' }
            expect(json_users).to include(a_hash_including('id' => article.author.id.to_s))
          end

          describe 'second level resources' do
            it 'includes only resources allowed by policy scope' do
              second_level_items = json_included.select { |item| item['type'] == 'comments' }

              expect(second_level_items.length).to eq(comments_policy_scope.length)
              expect(
                second_level_items.map { |i| i['id'] }
              ).to match_array(comments_policy_scope.pluck(:id).map(&:to_s))
            end
          end
        end
      end
    end
  end

  shared_examples_for :scope_limited_directive_test_modify_relationships do
    describe 'one-level deep has_many relationship' do
      let(:comments_policy_scope) { Comment.where(id: existing_comments.first.id) }
      let(:include_query) { 'comments' }

      context 'authorized for include_has_many_resource for Comment' do
        before {
          allow_operation(
            'include_has_many_resource',
            source_record: an_instance_of(Article),
            record_class: Comment,
            authorizer: chained_authorizer
          )
        }

        it { is_expected.to be_not_found }
      end
    end

    xdescribe 'multiple one-level deep relationships' do
      let(:include_query) { 'author,comments' }
      let(:comments_policy_scope) { Comment.where(id: existing_comments.first.id) }

      context 'authorized for both operations' do
        before do
          allow_operation('include_has_one_resource', source_record: an_instance_of(Article), related_record: an_instance_of(User), authorizer: chained_authorizer)
          allow_operation('include_has_many_resource', source_record: an_instance_of(Article), record_class: Comment, authorizer: chained_authorizer)
        end

        it { is_expected.to be_not_found }
      end
    end

    xdescribe 'a deep relationship' do
      let(:include_query) { 'author.comments' }
      let(:comments_policy_scope) { Comment.where(id: existing_author.comments.first.id) }

      context 'authorized for first relationship' do
        # before { allow_operation('include_has_one_resource', source_record: an_instance_of(Article), related_record: an_instance_of(User), authorizer: chained_authorizer) }

        context 'authorized for second relationship' do
          # before { allow_operation('include_has_many_resource', source_record: an_instance_of(User), record_class: Comment, authorizer: chained_authorizer) }

          it { is_expected.to be_not_found }
        end
      end
    end
  end

  describe 'GET /articles' do
    let(:article) {
      Article.create(
        external_id: "indifferent_external_id",
        author: User.create(
          comments: Array.new(2) { Comment.create }
        ),
        comments: Array.new(2) { Comment.create }
      )
    }

    let(:forbidden_policy) {
      { forbidden: { action: :index, klass: "Article"} }
    }
    let(:valid_policy) {
      { scope:
        {
          title: :by_article_id,
          message: article.id
        }
      }
    }
    let(:create_special_policy) {}

    subject(:last_response) { get("/articles?include=#{include_query}") }

    # TODO: Test properly with multiple articles, not just one.
    include_examples :include_directive_tests
    include_examples :scope_limited_directive_tests
  end

  describe 'GET /articles/:id' do
    let(:article) {
      Article.create(
        external_id: "indifferent_external_id",
        author: User.create(
          comments: Array.new(2) { Comment.create }
        ),
        comments: Array.new(2) { Comment.create }
      )
    }
    let(:forbidden_policy) { { forbidden: { klass: 'User', action: :show }} }
    let(:valid_policy) { { scope: { title: :by_author_id_for_comment, message: article.author.id }} }
    let(:create_special_policy) {}

    subject(:last_response) { get("/articles/#{article.external_id}?include=#{include_query}") }

    include_examples :include_directive_tests
    include_examples :scope_limited_directive_tests
  end

  describe 'PATCH /articles/:id' do
    let(:article) {
      Article.create(
        external_id: "indifferent_external_id",
        author: User.create(
          comments: Array.new(2) { Comment.create }
        ),
        comments: Array.new(2) { Comment.create }
      )
    }
    let(:forbidden_policy) { { forbidden: { action: :update, klass: 'Article'}} }
    let(:valid_policy) { { scope: { title: :by_article_id, message: article.id }} }
    let(:create_special_policy) {}

    let(:attributes_json) { '{}' }
    let(:json) do
      <<-EOS.strip_heredoc
      {
        "data": {
          "type": "articles",
          "id": "#{article.external_id}",
          "attributes": #{attributes_json}
        }
      }
      EOS
    end
    subject(:last_response) { patch("/articles/#{article.external_id}?include=#{include_query}", json) }

    include_examples :include_directive_tests
    include_examples :scope_limited_directive_tests

    context 'the request has already failed validations' do
      let(:include_query) { 'author.comments' }
      let(:attributes_json) { '{ "blank-value": "indifferent" }' }
      before {
        header 'POLICY', valid_policy
      }

      it 'does not run include authorizations and fails with validation error' do
        expect(last_response).to be_unprocessable
      end
    end
  end

  describe 'POST /articles/:id' do
    let(:existing_author) do
      User.create(
        comments: Array.new(2) { Comment.create }
      )
    end
    let(:forbidden_policy) { { forbidden: { action: :create, klass: 'Article' } } }
    let(:valid_policy) { {} }
    let(:create_special_policy) {
      { blank: :blank
      }
    }

    let(:existing_comments) do
      Array.new(2) { Comment.create }
    end

    let(:attributes_json) { '{}' }
    let(:json) do
      <<-EOS.strip_heredoc
      {
        "data": {
          "type": "articles",
          "id": "indifferent_external_id",
          "attributes": #{attributes_json},
          "relationships": {
            "comments": {
              "data": [
                { "type": "comments", "id": "#{existing_comments.first.id}" },
                { "type": "comments", "id": "#{existing_comments.second.id}" }
              ]
            },
            "author": {
              "data": {
                "type": "users", "id": "#{existing_author.id}"
              }
            }
          }
        }
      }
      EOS
    end
    let(:article) { existing_author.articles.first }

    subject(:last_response) { post("/articles?include=#{include_query}", json) }

    include_examples :include_directive_tests
    # include_examples :scope_limited_directive_test_modify_relationships

    context 'the request has already failed validations' do
      let(:include_query) { 'author.comments' }
      let(:attributes_json) { '{ "blank-value": "indifferent" }' }
      before {
        header 'POLICY', {}
      }

      it 'does not run include authorizations and fails with validation error' do
        expect(last_response).to be_unprocessable
      end
    end
  end

  describe 'GET /articles/:id/articles' do
    let(:article) {
      Article.create(
        external_id: "indifferent_external_id",
        author: User.create(
          comments: Array.new(2) { Comment.create }
        ),
        comments: Array.new(2) { Comment.create }
      )
    }
    let(:forbidden_policy) { { forbidden: { action: :show, klass: 'Article'}} }
    let(:valid_policy) { { scope: { title: :by_author_id_for_comment, message: article.author.id }} }
    let(:create_special_policy) {}

    subject(:last_response) { get("/articles/#{article.external_id}/articles?include=#{include_query}") }

    include_examples :include_directive_tests
    include_examples :scope_limited_directive_tests
  end

  describe 'GET /articles/:id/article' do
    let(:article) {
      Article.create(
        external_id: "indifferent_external_id",
        author: User.create(
          comments: Array.new(2) { Comment.create }
        ),
        comments: Array.new(2) { Comment.create }
      )
    }
    let(:forbidden_policy) { { forbidden: { action: :show, klass: 'Article'}} }
    let(:valid_policy) { { scope: { title: :by_author_id_for_comment, message: article.author.id }} }
    let(:create_special_policy) {}

    subject(:last_response) { get("/articles/#{article.external_id}/article?include=#{include_query}") }

    include_examples :include_directive_tests
    include_examples :scope_limited_directive_tests
  end
end
