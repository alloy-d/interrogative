require 'teststrap'

class NoQuestionsTest
  include Interrogative
end

class QuestionsTest
  include Interrogative

  question :has_questions, "Does this have questions?"
end

class SubclassWithNoQuestionsTest < QuestionsTest
end

class SubclassWithQuestionsTest < QuestionsTest
  question :is_subclass, "Is this a subclass?"
end

context "class with no questions" do
  setup { NoQuestionsTest }

  asserts(:questions).kind_of Array
  asserts(:questions).empty
end

context "class with one question" do
  context "(class)" do
    setup { QuestionsTest }

    denies(:questions).empty
    asserts(:questions).size(1)
  end

  context "(an instance)" do
    setup { QuestionsTest.new }

    denies(:questions).empty
    asserts(:questions).size(1)
  end

  context "(an instance with a question of its own)" do
    setup do
      QuestionsTest.new.tap {|q| q.question :is_instance, "Is this an instance?" }
    end

    asserts(:questions).size(2)
  end
end

context "subclass with no questions of its own" do
  setup { SubclassWithNoQuestionsTest }

  denies(:questions).empty
end

context "subclass with a question of its own" do
  setup { SubclassWithQuestionsTest }

  denies(:questions).empty
  asserts(:questions).size(2)

  context "(instance)" do
    setup { SubclassWithQuestionsTest.new }

    denies(:questions).empty
    asserts(:questions).size(2)
  end

  context "(instance with a question of its own)" do
    setup do
      SubclassWithQuestionsTest.new.tap {|i| i.question :is_instance, "Is this an instance?" }
    end

    asserts(:questions).size(3)
  end
end
