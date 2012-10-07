require 'test_helper'
require 'explain/visitor'

module Explain
  describe Visitor do
    let(:code) { "a = 123".to_ast }
    let(:visitor) { Visitor.new }

    def self.compiles(code, expected)
      it "explains #{code}" do
        visitor.visit(code.to_ast)
        visitor.output.must_equal(expected)
      end
    end

    # Basic types
    compiles %q{123},
      %q{the number 123}
    compiles %q{12.3},
      %q{the number 12.3}
    compiles %q{:hey},
      %q{the name `hey`}
    compiles %q{"hey"},
      %q{the word "hey"}

    compiles %q{true},
      %q{the truth}
    compiles %q{false},
      %q{the falsehood}
    compiles %q{nil},
      %q{the nothingness}

    compiles %q{[]},
      %q{an empty list}
    compiles %q{["hey", 9.9, 123]},
      %q{a list of the word "hey", the number 9.9 and the number 123}
    compiles %q{{}},
      %q{an empty dictionary}
    compiles %q{{:foo => "bar", :baz => 123}},
      %q{a dictionary where the name `foo` relates to the word "bar" and the name `baz` relates to the number 123}

    # Assignments
    compiles %q{a = 123},
      %q{We define as `a` the number 123}
    compiles %q{name = "John"},
      %q{We define as `name` the word "John"}

    compiles %q{def ret_name; name = "John"; name; end},
      %Q{\n\nLet's define a method: **ret_name**. This is described as follows: we define as `name` the word "John". Finally we return what we previously defined as `name`.}
    compiles %q{@name},
      %q{its name}
    compiles %q{@name = "John"},
      %q{Its name will be the word "John"}

    # Classes and modules
    compiles %q{class Person; end},
      %Q{Let's describe the general attributes and behavior of any Person.\nAnd with this we're done describing a Person.}

    compiles %q{class Person
                  def walk(distance)
                    @position += distance
                    update_hunger 1
                  end
                end},
      %Q{Let's describe the general attributes and behavior of any Person.\n\nA Person can **walk**, given a specific distance. This is described as follows: its position will be its position plus what we previously defined as `distance`. Finally we return the result of calling **update_hunger** given the number 1..\nAnd with this we're done describing a Person.}

    # Control flow
    compiles %q{if true
                  false
                else
                  :foo
                end},
      %Q{if the truth is truthy, then the falsehood -- else, the name `foo`}

    compiles %q{number = 0
                while number < 3
                  number += 1
                end},
      %Q{We define as `number` the number 0. while what we previously defined as `number` is less than the number 3, we define as `number` what we previously defined as `number` plus the number 1.}

    compiles %q{number = 0
                until number == 3
                  number += 1
                end},
      %Q{We define as `number` the number 0. until what we previously defined as `number` is equal to the number 3, we define as `number` what we previously defined as `number` plus the number 1.}

    compiles %q{return 3},
      %Q{We return the number 3}
  end
end
