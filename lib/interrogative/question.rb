require 'json'
require 'yaml'

module Interrogative

  # A question with a unique name and a textual representation.
  #
  # Designed to translate well into an HTML form element without
  # betraying the fact that it's meant to transform into an HTML form
  # element.
  class Question
    attr_accessor :name, :text, :attrs, :instance

    # @see Interrogative#question
    def initialize(name, text, owner=nil, attrs={}, &instance_block)
      @name = name or raise ArgumentError, "A question must have a name."
      @text = text or raise ArgumentError, "A question must have a label."
      @owner = owner
      @attrs = attrs
      @instance = nil
      @instance_block = instance_block
    end

    # Return a copy of this question, deep copying fields where appropriate.
    #
    # Currently, the only field that is deep copied is `attrs`.
    def clone
      q = super
      q.attrs = self.attrs.clone
      return q
    end

    # Returns a copy of this question that is bound to some object.
    #
    # This object will be used as the instance on which the `instance_block`,
    # if provided, is `instance_eval`ed.
    def for_instance(instance)
      self.clone.tap{|q| q.instance = instance }
    end

    # Possible answers for the question.
    #
    # If a block was passed to the initializer, then the result of
    # that block is returned. If the `instance` argument is provided,
    # the block will be `instance_eval`ed in the context of that
    # instance.
    #
    # Returns `nil` unless the class that included Interrogative
    # responds to a method called `#{ name }_options`; otherwise, it
    # returns the result of calling that method.
    #
    # Options should be either an Array or a Hash.
    # In the case of a Hash, the format should be `{ text => value }`.
    #
    # @return [Array, Hash] the possible answers for the question.
    def options
      if (@instance_block)
        if not @instance.nil?
          return @instance.instance_eval &@instance_block
        else
          return @instance_block.call
        end
      end

      return nil if @owner.nil?

      options_method = "#{@name}_options".intern
      if @owner.respond_to? options_method
        return @owner.send options_method
      end
    end

    # Returns a hash representation of the question.
    #
    # Attributes are merged into the top level, along with `:text` and
    # `:name`. Possible options are nested under `:options`.
    #
    # @return [Hash]
    def to_hash
      h = @attrs.merge({
        :text => text,
        :name => name,
      })

      o = options
      h[:options] = o if not o.nil?
      return h
    end

    # Returns a JSON object created from the question's hash
    # representation.
    #
    # @return [String]
    # @see #to_hash
    def to_json(opts={})
      self.to_hash.to_json(opts)
    end
  end
end

