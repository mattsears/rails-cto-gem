# frozen_string_literal: true

module RuboCop
  module Cop
    module RailsCTO
      # Enforces the mandatory Minitest::Spec `subject` convention from the
      # rails-cto plugin's rails-cto-minitest skill:
      #
      #   1. Every `*_test.rb` test class must define `subject { ... }` exactly
      #      once at the top level of the class body.
      #   2. `subject` must not be reassigned inside a nested `describe` or
      #      `it` block.
      #
      # @example
      #   # bad — no subject at top level
      #   class UserTest < ActiveSupport::TestCase
      #     describe "#full_name" do
      #       it "returns the name" do
      #         user = Fabricate(:user)
      #         assert_equal "Ada", user.full_name
      #       end
      #     end
      #   end
      #
      #   # bad — subject reassigned inside nested describe
      #   class UserTest < ActiveSupport::TestCase
      #     subject { Fabricate(:user) }
      #
      #     describe "#admin?" do
      #       subject { Fabricate(:user, role: :admin) } # offense
      #     end
      #   end
      #
      #   # good
      #   class UserTest < ActiveSupport::TestCase
      #     let(:attributes) { {} }
      #     subject { Fabricate.build(:user, **attributes) }
      #
      #     describe "#admin?" do
      #       let(:attributes) { { role: :admin } }
      #
      #       it "returns true" do
      #         assert_predicate subject, :admin?
      #       end
      #     end
      #   end
      class MinitestSubject < Base
        MSG_MISSING = "Define `subject { ... }` exactly once at the top of the test class."
        MSG_NESTED  = "Do not reassign `subject` inside nested describe/it blocks."

        def_node_matcher :subject_block?, <<~PATTERN
          (block (send nil? :subject) _ _)
        PATTERN

        def_node_matcher :describe_or_it_block?, <<~PATTERN
          (block (send nil? {:describe :it :specify :context} ...) _ _)
        PATTERN

        def on_class(node)
          return unless test_file?

          body = node.body
          return unless body

          children = body.begin_type? ? body.children : [body]
          return unless contains_spec_constructs?(children)

          add_offense(node, message: MSG_MISSING) if children.none? { |child| subject_block?(child) }
          nested_subject_blocks(children).each { |nested| add_offense(nested, message: MSG_NESTED) }
        end

        private

        def test_file?
          path = processed_source.file_path
          return false unless path

          path.end_with?("_test.rb")
        end

        def contains_spec_constructs?(nodes)
          nodes.any? { |child| spec_construct_in?(child) }
        end

        def spec_construct_in?(node)
          return true if describe_or_it_block?(node)
          return false unless node.is_a?(::RuboCop::AST::Node)

          node.each_descendant(:block).any? { |block| describe_or_it_block?(block) }
        end

        def nested_subject_blocks(children)
          children.flat_map { |child| descendant_subject_blocks(child) }
        end

        def descendant_subject_blocks(node)
          return [] unless node.is_a?(::RuboCop::AST::Node)

          node.each_descendant(:block).select { |block| subject_block?(block) }
        end
      end
    end
  end
end
