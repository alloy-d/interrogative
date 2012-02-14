require 'interrogative/question'

# A mixin for curious classes.
module Interrogative
  # Get the array of all noted questions.
  #
  # @return [Array<Question>] array of all noted questions.
  def questions; @_questions; end

  # Get the array of question postprocessors.
  #
  # @return [Array<Proc>] array of all registered postprocessors.
  def _question_postprocessors; @_question_postprocessors; end

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
    
    unless _question_postprocessors.nil?
      _question_postprocessors.each do |postprocessor|
        postprocessor.call(q)
      end
    end

    return q
  end
end

