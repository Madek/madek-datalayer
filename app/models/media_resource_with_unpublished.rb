class MediaResourceWithUnpublished < ActiveRecord::Base

  include Concerns::MediaResourceScope

  def self.unified_scope(scope1, scope2, scope3)
    scope1 = scope1.rewhere(is_published: [true, false])
    shared_unified_scope(scope1, scope2, scope3)
  end
end
