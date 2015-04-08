class ExistingRubricGradesSerializer < ActiveModel::Serializer
  attributes :id, :metric_id, :tier_id, :comments
end
