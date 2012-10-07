require "explain/version"
require "explain/visitor"

module Explain
  def self.explain(code)
    visitor = Visitor.new
    visitor.visit(code.to_ast)
    visitor.output
  end
end
