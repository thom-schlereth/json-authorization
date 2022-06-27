require_relative '../test_helper.rb'
require 'minitest/autorun'

class TrickyOperationsTest < ActionDispatch::IntegrationTest
  let (:article) { create(:article) }

  let(:headers) {
    {
      'Content-Type' => 'application/vnd.api+json',
      'status-type' => 201
    }
  }

  describe 'POST /comments (with relationships link to articles)' do

    let(:params) {
      {
        data: {
          type: "comments",
          relationships: {
            article: {
              data: {
                id: "#{article.external_id}",
                type: "articles"
              }
            }
          }
        }
      }
    }

    test 'authorized for create_resource on Comment and newly associated article' do
      # get("/articles/#{article.external_id}/relationships/author", headers: headers)
      post '/comments', params: params.to_json, headers: headers
      expect(status).to eq(201)
    end

    test 'unauthorized for create_resource on Comment and newly associated article' do
      headers['status-type'] = 403
      post '/comments', params: params.to_json, headers: headers
      expect(status).to eq(403)
    end

    test 'unauthorized for create_resource on Comment which is out of scope' do
      headers['status-type'] = 404
      post '/comments', params: params.to_json, headers: headers
      expect(status).to eq(404)
    end
  end

  describe 'POST /tags (with polymorphic relationship link to article)' do
    let(:params) {
      {
        data: {
          type: "tags",
          relationships: {
            taggable: {
              data: {
                id: "#{article.external_id}",
                type: "articles"
              }
            }
          }
        }
      }
    }

    test 'ppp' do
    # test 'authorized for create_resource on Tag and newly associated article' do
      post '/tags', params: params.to_json, headers: headers
      expect(status).to eq(201)
    end

  end
end
