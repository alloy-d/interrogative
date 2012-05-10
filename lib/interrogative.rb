require 'interrogative/question'

# A mixin for curious classes.
module Interrogative

  # Methods applicable on both the class and instance levels.
  module BaseMethods
    # Give instructions for dealing with new questions.
    #
    # @param [Proc] postprocessor a block to run after adding a question;
    #                             the question is given as the argument.
    def when_questioned(&postprocessor)
      (@_question_postprocessors||=[]) << postprocessor
    end

    # Give a new question.
    #
    # @param [Symbol, String] name the name (think <input name=...>) of
    #   the question.
    # @param [String] label the text of the question (think <label>).
    # @param [Hash] attrs additional attributes for the question.
    # @option attrs [Boolean] :long whether the question has a long answer
    #   (think <textarea> vs <input>).
    # @option attrs [Boolean] :multiple whether the question could have
    #   multiple answers.
    # @return [Question] the new Question.
    def question(name, text, attrs={})
      q = Question.new(name, text, self, attrs)
      (@_questions||=[]) << q
      
      unless @_question_postprocessors.nil?
        @_question_postprocessors.each do |postprocessor|
          postprocessor.call(q)
        end
      end

      return q
    end
  end

  # Methods tailored to the class level.
  #
  # These handle inheritance of questions.
  module ClassMethods
    include BaseMethods

    # Get the array of all noted questions.
    #
    # @return [Array<Question>] array of all noted questions.
    def questions
      qs = []
      qs |= superclass.questions if superclass.respond_to? :questions
      qs |= (@_questions||=[])
      qs
    end
  end

  # Methods tailored to the instance level.
  #
  # These handle getting questions from the class level.
  module InstanceMethods
    include BaseMethods

    def questions
      qs = []
      qs |= self.class.questions if self.class.respond_to? :questions
      qs |= (@_questions||=[])
      qs
    end
  end

  def self.included(base)
    base.extend(Interrogative::ClassMethods)
    base.instance_eval do
      include Interrogative::InstanceMethods
    end
  end
end

