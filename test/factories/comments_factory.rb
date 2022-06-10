FactoryBot.define do
  factory :comment do
    article { Article.first }
    author { User.first }
    reviewing_user { User.last }
  end
end
