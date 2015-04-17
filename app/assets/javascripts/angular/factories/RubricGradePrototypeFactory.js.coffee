@gradecraft.factory 'RubricGradePrototype', ->
	class RubricGradePrototype
		constructor: (attrs={})->
		  @id = attrs.id
		  @metric_id = attrs.metric_id
		  @tier_id = attrs.tier_id
		  @comments = attrs.comments