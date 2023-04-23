
<img src="https://cl.ly/aeaacddab2e2/graphoid.png" height="150" alt="graphoid"/>

[![CI](https://github.com/oxeanbits/graphoid/actions/workflows/build.yml/badge.svg?branch=master)](https://github.com/oxeanbits/graphoid/actions/workflows/build.yml)
[![Gem Version](https://img.shields.io/badge/gem%20version-0.2.0-green)](https://rubygems.org/gems/graphoid)
[![Maintainability](https://api.codeclimate.com/v1/badges/96505308310ca4e7e241/maintainability)](https://codeclimate.com/github/maxiperezc/graphoid/maintainability)

Generates a full GraphQL API using introspection of Mongoid or ActiveRecord models.

## API Documentation
The [API Documentation](https://maxcoto.github.io/graphoid/) that displays how to use the queries and mutations that Graphoid automatically generates.


## Dependency
This gem depends on [the GraphQL gem](https://github.com/rmosolgo/graphql-ruby).
Please install that gem first before continuing

## Installation
Add this line to your Gemfile:

```ruby
gem 'graphoid', git: 'https://github.com/oxeanbits/graphoid.git', tag: '0.2.0'
```

```bash
$ bundle install
```

## Database
Create the file `config/initializers/graphoid.rb`
And configure the database you want to use in it (:mongoid or :active_record)

```ruby
Graphoid.configure do |config|
  config.driver = :mongoid
end
```

## Usage
You can determine which models will be visible in the API by including the Graphoid Queries and Mutations concerns

```ruby
class Person
  include Graphoid::Queries
  include Graphoid::Mutations
end
```

## Examples
You can find an example that uses ActiveRecord in the [Tester AR folder](https://github.com/maxiperezc/graphoid/tree/master/spec/tester_ar)  
And an example with Mongoid in the [Tester Mongo folder](https://github.com/maxiperezc/graphoid/tree/master/spec/tester_mongo)  
In this same repository.



## Contributing
- Live Reload
- Aggregations
- Permissions on fields
- Relation with aliases tests
- Write division for "every" in Mongoid and AR
- Sort top level models by association values
- Filter by Array or Hash.
- has_one_through implementation
- has_many_selves tests
- has_and_belongs_to_many_selves tests
- Embedded::Many filtering implementation
- Embedded::One filtering with OR/AND


## Testing
```bash
$ DRIVER=ar DEBUG=true bundle exec rspec
$ DRIVER=mongo DEBUG=true bundle exec rspec
```

## Thank You !!
[Ryan Yeske](https://github.com/rcy) for the whole idea and for validating that metaprogramming this was possible.

[Andres Rafael](https://github.com/aandresrafael) for working so hard on connecting the gem on the frontend and finding its failures.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
