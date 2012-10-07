# explain

Explain explains your Ruby code in natural language. It is intended to be a
tool for beginners who aren't yet very familiar with programming.

It is a work in progress (a bit rough on the edges), so don't be mad. It will
get better over time ;)

(Explain runs only on Rubinius.)

## Installation

Install Rubinius if you don't have it yet:

    $ rvm install rbx-head
    $ rvm use rbx-head

Install explain as a gem:

    $ gem install explain

## Usage

Given some example Ruby code, for example this in `examples/person.rb`:

```ruby
class Person
  def walk(distance)
    @distance += distance
    @hunger += 2
  end

  def eat(food)
    @hunger -= food.nutritional_value
  end
end
```

We execute `explain` from the command line:

    $ explain examples/person.rb

And it will output:

    Let's describe the general attributes and behavior of any Person.

    A Person can **walk**, given a specific distance. This is described as
    follows: its distance will be its distance plus what we previously defined as
    `distance`. Finally we return its hunger will be its hunger plus the number
    2.. 

    A Person can **eat**, given a specific food. This is described as follows:
    Finally we return its hunger will be its hunger minus the result of calling
    **nutritional_value** on what we previously defined as `food`..
    And with this we're done describing a Person.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Who's this

This was made by [Josep M. Bach (Txus)](http://txustice.me) under the MIT
license. I'm [@txustice](http://twitter.com/txustice) on twitter (where you
should probably follow me!).
