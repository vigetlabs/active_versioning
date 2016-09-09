# ActiveVersioning

[![Gem Version](https://badge.fury.io/rb/active_versioning.svg)](http://badge.fury.io/rb/active_versioning) [![Code Climate](https://codeclimate.com/github/vigetlabs/active_versioning/badges/gpa.svg)](https://codeclimate.com/github/vigetlabs/active_versioning) [![Test Coverage](https://codeclimate.com/github/vigetlabs/active_versioning/badges/coverage.svg)](https://codeclimate.com/github/vigetlabs/active_versioning/coverage) [![Circle CI](https://circleci.com/gh/vigetlabs/active_versioning.svg?style=svg)](https://circleci.com/gh/vigetlabs/active_versioning)

ActiveVersioning provides out-of-the-box versioning functionality in Rails.  ActiveVersioning serializes attributes when records are saved and allows for version and draft management.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_versioning'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_versioning

Once installed, generate the necessary files and run migrations:

    $ rails generate active_versioning:install
    $ bundle exec rake db:migrate

## Setup

To set up versioning in your Rails app, include the following module in each model you'd like to version:
```ruby
class Post < ActiveRecord::Base
  include ActiveVersioning::Model::Versioned
end
```

## Working with Drafts

`ActiveVersioning::Model::Versioned` provides a number of methods for accessing and working with versions.

To access the current draft of a record, use...
```ruby
draft = post.current_draft
```
This returns a proxy object to a draft version of the record, so you can treat it like the `post` itself -- making changes and either saving or updating.
```ruby
draft.title = 'New Title'
draft.save

# or..

draft.update(title: 'New Title')
```
Both `save` and `update` will make changes to the draft version of the post.

When you are ready to overwrite the record with its draft, use...
```ruby
draft.commit(committer: 'Bob', commit_message: 'Update post title.')
```
This changes our post's attributes to match those of the draft and then marks the draft as a committed version.

If you want to throw away a draft:
```ruby
post.destroy_draft
```

## Working with Versions

A draft is just a version with a particular state.  To access all the versions for a particular record, use...
```ruby
post.versions              # => All versions, whether the version state is 'create', 'draft', or 'commit'
post.versions.draft        # => All draft versions
post.versions.committed    # => All non-draft versions
post.versions.newest_first # => All versions starting with the most recently created
```

You can use any existing version to create a new draft:
```ruby
old_version = post.versions.committed.first

post.create_draft_from_version(old_version.id)
```
This will set `post.current_draft`'s attributes to the attributes stored in the given version's record. Returns boolean based on the save's success.

## Capturing Version Metadata

In addition to manually committing a version with a committer and commit message...
```ruby
post.current_draft.commit(committer: 'Bob', commit_message: 'Update post title.')
```
ActiveVersioning provides a `version_author` accessor on any versioned model, so you can capture the author for a record's initial create:
```ruby
post = Post.create(title: 'Title', body: 'Body text.', version_author: 'Bob')

post.versions.first.version_author # => 'Bob'
```

## Viewing and Modifying Versioned Attributes

If you want to see the attributes the are versioned, use...
```ruby
post.versioned_attributes # => { 'id' => 1, 'title' => 'Default Title' }
```

By default, ActiveVersioning blacklists the following attributes:
```ruby
ActiveVersioning::VersionManager::BLACKLISTED_ATTRIBUTES = %w(
  created_at
  updated_at
  published
)
```

If you require additional versioned attributes, overwrite the `versioned_attribute_names` method in your model:
```ruby
class Post < ActiveRecord::Base
  private

  def versioned_attribute_names
   super + %w(photo_id)
  end
end
```

## Handling Incompatible Versions

In the case of a versioned model that undergoes a schema change, all previous versions may reference attributes that no longer exist.

In ActiveVersioning, we consider these incompatible versions.  An attempt to create a draft from an incompatible version will raise an error:
```
incompatible_version = post.versions.committed.last

incompatible_version.object
# => { 'deleted_attribute' => value }

post.create_draft_from_version(incompatible_version.id)
# => ActiveVersioning::Errors::IncompatibleVersion:
# The given version contains attributes that are no longer compatible with the current schema: deleted_attribute.
```

When rescued, the error object contains a reference to the record and the incompatible version:
```
begin
  post.create_draft_from_version(incompatible_version.id)
rescue ActiveVersioning::Errors::IncompatibleVersion => error
  error.record  # => our `post` record
  error.version # => our `incompatible_version`
end
```

***

<a href="http://code.viget.com">
  <img src="http://code.viget.com/github-banner.png" alt="Code At Viget">
</a>

Visit [code.viget.com](http://code.viget.com) to see more projects from [Viget.](https://viget.com)
