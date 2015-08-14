module Concerns
  module MediaResources
    module Highlight
      def highlighted_for?(collection)
        collection
          .send("highlighted_#{model_name.plural}")
          .exists?(id)
      end
    end
  end
end
