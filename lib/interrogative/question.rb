require 'json'
require 'yaml'

module Interrogative

  # A question with a unique name and a textual representation.
  #
  # Designed to translate well into an HTML form element without
  # betraying the fact that it's meant to transform into an HTML form
  # element.
  class Question
    attr_accessor :name, :text, :attrs

    # @see Interrogative#question
    def initialize(name, text, owner=nil, attrs={})
      @name = name or raise ArgumentError, "A question must have a name."
      @text = text or raise ArgumentError, "A question must have a label."
      @owner = owner
      @attrs = attrs
    end

    # Possible answers for the question.
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
      return nil if @owner.nil?

      options_method = "#{@name}_options".intern
      if @owner.respond_to? options_method
        @owner.send options_method
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

