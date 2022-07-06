Had to change gemfiles to use rails version 6.1.5

delete line `# config.exception_class_whitelist = [Pundit::NotAuthorizedError]`

/app/resources/tag_resource.rb
`has_one :taggable, polymorphic: true, always_include_linkage_data: true`


/app/resources/article_resource.rb
```
has_many :comments, acts_as_set: true, merge_resource_records: false
has_many :tags, acts_as_set: true, exclude_links: :default
```

/app/resources/comment_resource.rb
```
has_many :tags, acts_as_set: true, exclude_links: :default
has_one :article, merge_resource_records: false
```
