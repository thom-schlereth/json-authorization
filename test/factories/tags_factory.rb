FactoryBot.define do
  factory :article_tag do
    taggable { Article.first }
  end

  factory :comment_tag do
    taggable { Comment.first }
  end
end
