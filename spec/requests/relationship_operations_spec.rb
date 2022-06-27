require 'spec_helper'

RSpec.describe 'Relationship operations', type: :request do
  # include AuthorizationStubs
  fixtures :all

  let(:article) { Article.all.sample }
  let(:policy_scope) { Article.none }
  let(:valid_policy) {}

  let(:json_data) { JSON.parse(last_response.body)["data"] }

  before do
    header 'Content-Type', 'application/vnd.api+json'
  end

  describe 'GET /articles/:id/relationships/comments' do
    let(:article) { articles(:article_with_comments) }
    let(:comments_on_article) { article.comments }
    let(:comments_policy_scope) { comments_on_article.limit(1) }

    subject(:last_response) { get("/articles/#{article.external_id}/relationships/comments") }

    context 'unauthorized for show_relationship' do
      let(:forbidden_policy) { { forbidden: { action: :show, klass: "Article" } } }

      before {
        header 'POLICY', forbidden_policy
      }

      it { is_expected.to be_forbidden }
    end

    context 'authorized for show_relationship' do
      let(:valid_policy) {
        { scope: { title: :by_article_first_comment_id, article_id: article.external_id, comment_id: article.comments.first.id } }
      }
      before {
        header 'POLICY', valid_policy
      }

      it { is_expected.to be_ok }

      # If this happens in real life, it's mostly a bug. We want to document the
      # behaviour in that case anyway, as it might be surprising.
      context 'limited by ArticlePolicy::Scope' do
        let(:article_not_found_policy) {
          { scope: { title: :by_article_not_found, article_id: article.external_id } }
        }
        before {
          header 'POLICY', article_not_found_policy
        }
        it { is_expected.to be_not_found }
      end

      it 'displays only comments allowed by CommentPolicy::Scope' do
        expect(json_data.length).to eq(1)
        expect(json_data.first["id"]).to eq(comments_policy_scope.first.id.to_s)
      end
    end
  end

  describe 'GET /articles/:id/relationships/author' do
    subject(:last_response) { get("/articles/#{article.external_id}/relationships/author") }

    let(:article) { articles(:article_with_author) }

    context 'unauthorized for show_relationship' do
      let(:forbidden_policy) {
        { forbidden: { action: :show, klass: "Article"} }
      }

      before {
        header 'POLICY', forbidden_policy
      }

      it { is_expected.to be_forbidden }
    end

    context 'authorized for show_relationship' do
      let(:valid_policy) {
        { scope: { title: :by_article_external_id, article_id: article.external_id } }
      }
      before {
        header 'POLICY', valid_policy
      }

      it { is_expected.to be_ok }

      # If this happens in real life, it's mostly a bug. We want to document the
      # behaviour in that case anyway, as it might be surprising.
      context 'limited by policy scope' do
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

  describe 'POST /articles/:id/relationships/comments' do
    let(:new_comments) { Array.new(2) { Comment.new }.each(&:save) }
    let(:json) do
      <<-EOS.strip_heredoc
      {
        "data": [
          { "type": "comments", "id": "#{new_comments.first.id}" },
          { "type": "comments", "id": "#{new_comments.last.id}" }
        ]
      }
      EOS
    end
    subject(:last_response) { post("/articles/#{article.external_id}/relationships/comments", json) }

    context 'unauthorized for create_to_many_relationship' do
      let(:forbidden_policy) {
        { forbidden: { action: :create, klass: "Article"} }
      }

      before {
        header 'POLICY', forbidden_policy
      }
      it { is_expected.to be_forbidden }
    end

    context 'authorized for create_to_many_relationship' do
      it { is_expected.to be_successful }

      context 'limited by policy scope on comments' do
        let(:comments_not_found_policy) {
          { scope: { title: :by_comments_not_found, article_id: article.external_id, comment_ids: new_comments.pluck(:id) } }
        }
        before {
          header 'POLICY', comments_not_found_policy
        }
        it { is_expected.to be_not_found }
      end

      # If this happens in real life, it's mostly a bug. We want to document the
      # behaviour in that case anyway, as it might be surprising.
      context 'limited by policy scope on articles' do
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

  describe 'PATCH /articles/:id/relationships/comments' do
    let(:article) { articles(:article_with_comments) }
    let(:new_comments) { Array.new(2) { Comment.new }.each(&:save) }
    let(:json) do
      <<-EOS.strip_heredoc
      {
        "data": [
          { "type": "comments", "id": "#{new_comments.first.id}" },
          { "type": "comments", "id": "#{new_comments.last.id}" }
        ]
      }
      EOS
    end
    subject(:last_response) { patch("/articles/#{article.external_id}/relationships/comments", json) }

    context 'unauthorized for replace_to_many_relationship' do
      let(:forbidden_policy) {
        { forbidden: { action: :create, klass: "Article"} }
      }

      before {
        header 'POLICY', forbidden_policy
      }

      it { is_expected.to be_forbidden }
    end

    context 'authorized for replace_to_many_relationship' do
      context 'not limited by policy scopes' do
        it { is_expected.to be_successful }
      end

      context 'limited by policy scope on comments' do
        let(:forbidden_comment_ids) { new_comments.pluck(:id) }
        let(:comments_not_found_policy) {
          { scope: { title: :by_comments_not_found, article_id: article.external_id, comment_ids: new_comment_ids } }
        }
        before {
          header 'POLICY', comments_not_found_policy
        }

        # replace to many relationships dont trigger the pundit scope on the relationshp items
        xit { is_expected.to be_not_found }
      end

      # If this happens in real life, it's mostly a bug. We want to document the
      # behaviour in that case anyway, as it might be surprising.
      context 'limited by policy scope on articles' do
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

  describe 'PATCH /articles/:id/relationships/author' do
    subject(:last_response) { patch("/articles/#{article.external_id}/relationships/author", json) }

    let(:article) { articles(:article_with_author) }
    let!(:old_author) { article.author }

    describe 'when replacing with a new author' do
      let(:new_author) { User.create }
      let(:json) do
        <<-EOS.strip_heredoc
        {
          "data": {
            "type": "users",
            "id": "#{new_author.id}"
          }
        }
        EOS
      end

      context 'unauthorized for replace_to_one_relationship' do
        let(:forbidden_policy) {
          { forbidden: { action: :create, klass: "Article"} }
        }

        before {
          header 'POLICY', forbidden_policy
        }

        it { is_expected.to be_forbidden }
      end

      context 'authorized for replace_to_one_relationship' do
        it { is_expected.to be_successful }

        context 'limited by policy scope on author', skip: 'DISCUSS' do
          it { is_expected.to be_not_found }
        end

        # If this happens in real life, it's mostly a bug. We want to document the
        # behaviour in that case anyway, as it might be surprising.
        context 'limited by policy scope on article' do
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

    describe 'when nullifying the author' do
      let(:new_author) { nil }
      let(:json) { '{ "data": null }' }

      context 'unauthorized for remove_to_one_relationship' do
        let(:forbidden_policy) {
          { forbidden: { action: :destroy, klass: "Author"} }
        }

        before {
          header 'POLICY', forbidden_policy
        }

        it { is_expected.to be_forbidden }
      end

      context 'authorized for remove_to_one_relationship' do
        it { is_expected.to be_successful }

        context 'limited by policy scope on author', skip: 'DISCUSS' do
          # let(:user_policy_scope) { User.where.not(id: article.author.id) }
          it { is_expected.to be_not_found }
        end

        # If this happens in real life, it's mostly a bug. We want to document the
        # behaviour in that case anyway, as it might be surprising.
        context 'limited by policy scope on article' do
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
  end

  # Polymorphic has-one relationship replacing
  describe 'PATCH /tags/:id/relationships/taggable' do
    subject(:last_response) { patch("/tags/#{tag.id}/relationships/taggable", json) }

    let!(:old_taggable) { Comment.create }
    let!(:tag) { Tag.create(taggable: old_taggable) }

    describe 'when replacing with a new taggable' do
      let!(:new_taggable) { Article.create(external_id: 'new-article-id') }
      let(:json) do
        <<-EOS.strip_heredoc
        {
          "data": {
            "type": "Article",
            "id": "#{new_taggable.external_id}"
          }
        }
        EOS
      end

      context 'unauthorized for replace_to_one_relationship' do
        let(:forbidden_policy) {
          { forbidden: { action: :update, klass: "Tag"} }
        }

        before {
          header 'POLICY', forbidden_policy
        }

        it { is_expected.to be_forbidden }
      end

      context 'authorized for replace_to_one_relationship' do
        it {
          skip "Fails as jsonapi-resources incorrectly updates Tag."
          is_expected.to be_successful
          #JR can't set a custom key. Article uses external_id instead of id
          #JR also sets the 'type' to be lowercase, 'article,' instead of, 'Article,' which causes:
          #NameError: wrong constant name article
          expect(Tag.last.taggable).to eq(new_taggable)
         }

        context 'limited by policy scope on taggable', skip: 'DISCUSS' do
          let(:policy_scope) { Article.where.not(id: tag.taggable.id) }
          it { is_expected.to be_not_found }
        end

        # If this happens in real life, it's mostly a bug. We want to document the
        # behaviour in that case anyway, as it might be surprising.
        context 'limited by policy scope on tag' do
          let(:tag_not_found_policy) {
            { scope: { title: :by_tag_not_found, tag_id: "#{tag.id}" } }
          }
          before {
            header 'POLICY', tag_not_found_policy
          }

          it { is_expected.to be_not_found }
        end
      end
    end

    # https://github.com/cerebris/jsonapi-resources/issues/1081
    describe 'when nullifying the taggable', skip: 'Broken upstream' do
      let(:new_taggable) { nil }
      let(:json) { '{ "data": null }' }

      context 'unauthorized for remove_to_one_relationship' do
        let(:forbidden_policy) {
          { forbidden: { action: :update, klass: "Tag"} }
        }

        before {
          header 'POLICY', forbidden_policy
        }

        it { is_expected.to be_forbidden }
      end

      context 'authorized for remove_to_one_relationship' do
        before { allow_operation('remove_to_one_relationship', source_record: tag, relationship_type: :taggable) }
        it { is_expected.to be_successful }

        context 'limited by policy scope on taggable', skip: 'DISCUSS' do
          let(:policy_scope) { Article.where.not(id: tag.taggable.id) }
          it { is_expected.to be_not_found }
        end

        # If this happens in real life, it's mostly a bug. We want to document the
        # behaviour in that case anyway, as it might be surprising.
        context 'limited by policy scope on tag' do
          let(:tag_policy_scope) { Tag.where.not(id: tag.id) }
          it { is_expected.to be_not_found }
        end
      end
    end
  end

  describe 'DELETE /articles/:id/relationships/comments' do
    let(:article) { articles(:article_with_comments) }
    let(:comments_to_remove) { article.comments.limit(2) }
    let(:json) do
      <<-EOS.strip_heredoc
      {
        "data": [
          { "type": "comments", "id": "#{comments_to_remove.first.id}" },
          { "type": "comments", "id": "#{comments_to_remove.last.id}" }
        ]
      }
      EOS
    end
    subject(:last_response) { delete("/articles/#{article.external_id}/relationships/comments", json) }

    context 'unauthorized for remove_to_many_relationship' do
      before do
      end
      let(:forbidden_policy) {
        { forbidden: { action: :destroy, klass: "Comment"} }
      }

      before {
        header 'POLICY', forbidden_policy
      }

      it { is_expected.to be_forbidden }
    end

    context 'authorized for remove_to_many_relationship' do
      context 'not limited by policy scopes' do
        it { is_expected.to be_successful }
      end

      context 'limited by policy scope on comments' do
        let(:comments_cant_be_destroyed) {
          { scope: { title: :by_comments_cant_be_destroyed } }
        }
        before {
          header 'POLICY', comments_cant_be_destroyed
        }

        it {
          is_expected.to be_not_found }
      end

      # If this happens in real life, it's mostly a bug. We want to document the
      # behaviour in that case anyway, as it might be surprising.
      context 'limited by policy scope on articles' do
        let(:article_not_found) {
          { scope: { title: :by_article_not_found, article_id: article.external_id } }
        }
        before {
          header 'POLICY', article_not_found
        }

        it { is_expected.to be_not_found }
      end
    end
  end

  describe 'DELETE /articles/:id/relationships/author' do
    subject(:last_response) { delete("/articles/#{article.external_id}/relationships/author") }
    let(:article) { articles(:article_with_author) }

    context 'unauthorized for remove_to_one_relationship' do
      let(:forbidden_policy) {
        { forbidden: { action: :destroy, klass: "Author"} }
      }

      before {
        header 'POLICY', forbidden_policy
      }

      it { is_expected.to be_forbidden }
    end

    context 'authorized for remove_to_one_relationship' do
      it { is_expected.to be_successful }

      # If this happens in real life, it's mostly a bug. We want to document the
      # behaviour in that case anyway, as it might be surprising.
      context 'limited by policy scope' do
        let(:article_not_found) {
          { scope: { title: :by_article_not_found, article_id: article.external_id } }
        }
        before {
          header 'POLICY', article_not_found
        }

        it { is_expected.to be_not_found }
      end
    end
  end
end
