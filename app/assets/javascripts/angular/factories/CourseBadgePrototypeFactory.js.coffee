@gradecraft.factory 'CourseBadgePrototype', ->
  class CourseBadgePrototype
	  constructor: (attrs={}) ->
	  	@id = attrs.id
	  	@name = attrs.name
	  	@description = attrs.description
	  	@point_total = attrs.point_total
	  	@icon = attrs.icon
	  	@multiple = attrs.multiple