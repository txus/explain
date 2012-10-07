module Explain
  class Visitor
    def initialize
      @output = []
    end

    def visit(node, in_sentence=false)
      __send__ node.node_name, node, in_sentence
    end

    def emit(str)
      @output.push str
    end

    def output
      @output.join
    end

    def class(node, in_sentence=false)
      @in_class = node.name.name
      emit "Let's describe the general attributes and behavior of any #{node.name.name}."
      visit node.body
      emit "\nAnd with this we're done describing a #{node.name.name}."
      @in_class = nil
    end

    def module(node, in_sentence=false)
      @in_class = node.name.name
      emit "Let's describe a collection of behavior that we'll call #{node.name.name}."
      visit node.body
      emit "\nAnd with this we're done describing #{node.name.name}."
      @in_class = nil
    end

    def empty_body(*)
      # do nothing
    end

    def class_scope(node, in_sentence=false)
      visit node.body
    end
    alias module_scope class_scope

    def local_variable_assignment(node, in_sentence=false)
      emit in_sentence ? "w" : "W"
      emit "e define as `#{node.name}` "
      visit(node.value)
    end

    def local_variable_access(node, in_sentence=false)
      emit "what we previously defined as `#{node.name}`"
    end

    def instance_variable_assignment(node, in_sentence=false)
      emit in_sentence ? "i" : "I"
      emit "ts #{node.name[1..-1]} will be "
      visit(node.value)
    end

    def instance_variable_access(node, in_sentence=false)
      emit "its #{node.name[1..-1]}"
    end

    def fixnum_literal(node, in_sentence=false)
      emit "the number #{node.value}"
    end

    def float_literal(node, in_sentence=false)
      emit "the number #{node.value}"
    end

    def string_literal(node, in_sentence=false)
      emit "the word \"#{node.string}\""
    end

    def symbol_literal(node, in_sentence=false)
      emit "the name `#{node.value}`"
    end

    def true_literal(node, in_sentence=false)
      emit "the truth"
    end

    def false_literal(node, in_sentence=false)
      emit "the falsehood"
    end

    def nil_literal(node, in_sentence=false)
      emit "the nothingness"
    end

    def empty_array(node, in_sentence=false)
      emit "an empty list"
    end

    def array_literal(node, in_sentence=false)
      body = node.body
      emit "a list of "
      body.each_with_index do |node, index|
        visit node
        if body.length == index + 2 # last element
          emit " and "
        elsif body.length != index + 1
          emit ", "
        end
      end
    end

    def hash_literal(node, in_sentence=false)
      return emit "an empty dictionary" if node.array.empty?

      body = node.array.each_slice(2)

      emit 'a dictionary where '
      body.each_with_index do |slice, index|
        key, value = slice

        visit key
        emit " relates to "
        visit value

        if body.to_a.length == index + 2 # last element
          emit " and "
        elsif body.to_a.length != index + 1
          emit ", "
        end
      end
    end

    # def range(node, in_sentence=false)
    # end

    # def range_exclude(node, in_sentence=false)
    # end

    # def regex_literal(node, in_sentence=false)
    # end

    def send(node, in_sentence=false)
      if node.receiver.is_a?(Rubinius::AST::Self)
        emit in_sentence ? "the result of calling " : "We "
        emit "**#{node.name}**"
      else
        emit in_sentence ? "the result of calling " : "We call "
        emit "**#{node.name}** on "
        visit node.receiver
      end
    end

    def send_with_arguments(node, in_sentence=false)
      return if process_binary_operator(node, in_sentence) # 1 * 2, a / 3, true && false

      if node.receiver.is_a?(Rubinius::AST::Self)
        emit in_sentence ? "the result of calling " : "We "
        emit "**#{node.name}**"
      else
        emit in_sentence ? "the result of calling " : "We call "
        emit "**#{node.name}** on "
        visit node.receiver
      end

      unless node.arguments.array.empty?
        emit " given "
        visit(node.arguments)
      end
    end

    def actual_arguments(node, in_sentence=false)
      body = node.array
      body.each_with_index do |node, index|
        visit node
        if body.length == index + 2 # last element
          emit " and "
        elsif body.length != index + 1
          emit ", "
        end
      end
    end

    # def iter_arguments(node, in_sentence=false)
    # end

    # def iter(node, in_sentence=false)
    # end

    def block(node, in_sentence=false)
      body = node.array
      body.each_with_index do |node, index|
        if body.length == index + 1 # last element
          if @in_method
          emit "Finally we return "
          end
          visit node, true
          emit "."
        else
          visit node, in_sentence
          emit '. '
        end
      end
    end

    # def not(node, in_sentence=false)
    # end

    # def and(node, in_sentence=false)
    # end

    # def or(node, in_sentence=false)
    # end

    # def op_assign_and(node, in_sentence=false)
    # end

    # def op_assign_or(node, in_sentence=false)
    # end

    # def toplevel_constant(node, in_sentence=false)
    # end

    # def constant_access(node, in_sentence=false)
    # end

    # def scoped_constant(node, in_sentence=false)
    # end

    def if(node, in_sentence=false)
      body, else_body = node.body, node.else
      keyword = 'if'

      if node.body.is_a?(Rubinius::AST::NilLiteral) && !node.else.is_a?(Rubinius::AST::NilLiteral)

        body, else_body = else_body, body
        keyword = 'unless'
      end

      emit "#{keyword} "
      visit node.condition, true
      emit " is truthy, then "

      visit body, true

      if else_body.is_a?(Rubinius::AST::NilLiteral)
        return
      end

      emit " -- else, "

      visit else_body, true
    end

    def while(node, in_sentence=false)
      emit in_sentence ? "w" : "W"
      emit 'hile '
      visit node.condition, true
      emit ", "
      visit node.body, true
    end

    def until(node, in_sentence=false)
      emit in_sentence ? "u" : "U"
      emit 'ntil '
      visit node.condition, true
      emit ", "
      visit node.body, true
    end

    def return(node, in_sentence=false)
      emit in_sentence ? "w" : "W"
      emit "e return "
      visit node.value
    end

    def define(node, in_sentence=false)
      args = enumerate(node.arguments.names)

      if @in_class
        emit "\n\nA #{@in_class} can **#{node.name}**"
      else
        emit "\n\nLet's define a method: **#{node.name}**"
      end
      if node.arguments.names.empty?
        emit "."
      else
        emit ", given a specific #{args}." 
      end

      unless node.body.array.first.is_a?(Rubinius::AST::NilLiteral) && node.body.array.length == 1
        @in_method = true
        emit " This is described as follows: "
        visit node.body, true
        @in_method = false
      end
    end

    def method_missing(m, *args, &block)
      emit "(eerr I don't know how to explain `#{m}`)"
    end

    private

    def enumerate(ary)
      comma_joinable = ary[0..-2]
      if comma_joinable.empty?
        "#{ary[-1]}"
      else
        [comma_joined.join(', '), ary[-1]].join(' and ')
      end
    end

    def process_binary_operator(node, in_sentence)
      operators = %w(+ - * / & | << < > >= <= == !=).map(&:to_sym)
      return false unless operators.include?(node.name)
      return false if node.arguments.array.length != 1

      operand = node.arguments.array[0]

      unless node.receiver.is_a?(Rubinius::AST::Self)
        visit node.receiver
      end

      emit case node.name.to_s
           when "+" then " plus "
           when "-" then " minus "
           when "*" then " times "
           when "/" then " divided by "
           when "<" then " is less than "
           when ">" then " is greater than "
           when ">=" then " is greater or equal than "
           when "<=" then " is less or equal than "
           when "==" then " is equal to "
           when "!=" then " is different than "
           end

      visit operand, true
    end
  end
end
